module Radar
  class Support
    class Hash
      #----------------------------------------------------------------------
      # Deep Merging - Taken from Ruby on Rails ActiveSupport
      #----------------------------------------------------------------------

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
  end
end
