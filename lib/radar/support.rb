module Radar
  class Support
    # Hash support methods:
    #
    # * {#deep_merge} and {#deep_merge!} - Does what it says: deep merges a
    #   hash with another hash. Taken from ActiveSupport in Rails 3.
    #
    class Hash
      # Returns a new hash with +self+ and +other_hash+ merged recursively.
      def self.deep_merge(source, other)
        deep_merge!(source.dup, other)
      end

      # Returns a new hash with +self+ and +other_hash+ merged recursively.
      # Modifies the receiver in place.
      def self.deep_merge!(source, other)
        other.each_pair do |k,v|
          tv = source[k]
          source[k] = tv.is_a?(::Hash) && v.is_a?(::Hash) ? deep_merge(tv, v) : v
        end

        source
      end
    end

    # Inflector methods:
    #
    # * {#camelize} - Convert a string or symbol to UpperCamelCase.
    # * {#constantize} - Convert a string to a constant.
    #
    # Both of these inflector methods are taken directly from ActiveSupport
    # in Rails 3.
    class Inflector
      def self.camelize(string)
        string.to_s.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
      end

      def self.constantize(camel_cased_word)
        names = camel_cased_word.split('::')
        names.shift if names.empty? || names.first.empty?
        names.inject(Object) do |acc, name|
          acc.const_defined?(name) ? acc.const_get(name) : acc.const_missing(name)
        end
      end
    end
  end
end
