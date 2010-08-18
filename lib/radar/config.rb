require 'forwardable'

module Radar
  # The configuration class used for applications. To configure your application
  # see {Application#config}. This is also where all the examples are.
  class Config
    attr_reader :reporters
    attr_reader :data_extensions
    attr_reader :matchers
    attr_accessor :log_location

    def initialize
      @reporters = UseArray.new do |klass, &block|
        instance = klass.new
        block.call(instance) if block
        [klass, instance]
      end

      @data_extensions = UseArray.new
      @data_extensions.use DataExtensions::HostEnvironment

      @matchers = UseArray.new do |matcher, *args|
        matcher = Support::Inflector.constantize("Radar::Matchers::#{Support::Inflector.camelize(matcher)}Matcher") if !matcher.is_a?(Class)
        [matcher, matcher.new(*args)]
      end

      @log_location = lambda { |application| File.expand_path("~/.radar/logs/#{application.name.to_s}.log") }
    end

    # Adds a matcher rule to the application. An application will only
    # report an exception if the event agrees with at least one of the
    # matchers.
    #
    # To use a matcher, there are two options. The first is to use a
    # symbol for the name:
    #
    #     config.match :class, StandardError
    #
    # This will cause Radar to search for a class named "ClassMatcher"
    # under the namespace {Radar::Matchers}.
    #
    # A second option is to use a class itself:
    #
    #     config.match Radar::Matchers::ClassMatcher, StandardError
    #
    # Radar will then use the specified class as the matcher.
    #
    def match(matcher, *args)
      @matchers.use(matcher, *args)
    end
  end

  class Config
    # A subclass of Array which allows for slightly different usage, based
    # on `ActionDispatch::MiddlewareStack` in Rails 3. The main methods are
    # enumerated below:
    #
    # - {#use}
    # - {#insert}
    # - {#insert_before}
    # - {#insert_after}
    # - {#swap}
    # - {#delete}
    #
    class UseArray
      extend Forwardable
      def_delegators :@_array, :empty?, :length, :clear

      # Initializes the UseArray with the given block used to generate
      # the value created for the {#use} method. The block given determines
      # how the {#use} method stores the key/value.
      def initialize(*args, &block)
        @_array = []
        @_use_block = block || Proc.new { |key, *args| [key, key] }
      end

      # Use the given key. It is up to the configured use block (given by
      # the initializer) to generate the actual key/value stored in the array.
      def use(*args, &block)
        insert(length, *args, &block)
      end

      # Insert the given key at the given index or directly before the
      # given object (by key).
      def insert(key, *args, &block)
        @_array.insert(index(key), @_use_block.call(*args, &block))
      end
      alias_method :insert_before, :insert

      # Insert after the given key.
      def insert_after(key, *args, &block)
        i = index(key)
        raise ArgumentError.new("No such key found: #{key}") if !i
        insert(i + 1, *args, &block)
      end

      # Swaps out the given object at the given index or key with a new
      # object.
      def swap(key, *args, &block)
        i = index(key)
        raise ArgumentError.new("No such key found: #{key}") if !i
        delete(i)
        insert(i, *args, &block)
      end

      # Delete the object with the given key or index.
      def delete(key)
        @_array.delete_at(index(key))
      end

      # Returns the value for the given key. If the key is an integer,
      # it is returned as-is. Otherwise, do a lookup on the array for the
      # the given key and return the index of it.
      def index(key)
        return key if key.is_a?(Integer)
        @_array.each_with_index do |data, i|
          return i if data[0] == key
        end

        nil
      end

      # Returns the values of this array.
      def values
        @_array.inject([]) do |acc, data|
          acc << data[1]
          acc
        end
      end
    end
  end
end
