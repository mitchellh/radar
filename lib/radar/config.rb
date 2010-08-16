require 'forwardable'

module Radar
  class Config
    attr_reader :reporters
    attr_reader :data_extensions

    def initialize
      @reporters = []
      @data_extensions = [DataExtensions::HostEnvironment]
    end

    # Add a reporter to an application. If a block is given, it
    # will be yielded later (since reporters are initialized lazily)
    # with the instance of the reporter.
    #
    # @param [Class] klass A {Reporter} class.
    def reporter(klass)
      instance = klass.new
      yield instance if block_given?
      @reporters << instance
    end

    # Adds a data extension to an application. Data extensions allow
    # extra data to be included into an {ExceptionEvent} (they appear
    # in the {ExceptionEvent#to_hash} output). For more information,
    # please read the Radar user guide.
    #
    # This method takes a class. This class is expected to be initialized
    # with an {ExceptionEvent}, and must implement the `to_hash` method.
    #
    # @param [Class] klass
    def data_extension(klass)
      @data_extensions << klass
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
      def_delegators :@_array, :empty?, :length

      # Initializes the UseArray with the given block used to generate
      # the value created for the {#use} method. The block given determines
      # how the {#use} method stores the key/value.
      def initialize(*args, &block)
        @_array = []
        @_use_block = block || Proc.new { |key, *args| [key, key] }
      end

      # Use the given key. It is up to the configured use block (given by
      # the initializer) to generate the actual key/value stored in the array.
      def use(*args)
        insert(length, *args)
      end

      # Insert the given key at the given index or directly before the
      # given object (by key).
      def insert(key, *args)
        @_array.insert(index(key), @_use_block.call(*args))
      end
      alias_method :insert_before, :insert

      # Insert after the given key.
      def insert_after(key, *args)
        i = index(key)
        raise ArgumentError.new("No such key found: #{key}") if !i
        insert(i + 1, *args)
      end

      # Swaps out the given object at the given index or key with a new
      # object.
      def swap(key, *args)
        i = index(key)
        raise ArgumentError.new("No such key found: #{key}") if !i
        delete(i)
        insert(i, *args)
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
