module Radar
  class Config
    attr_reader :reporters

    def initialize
      @reporters = []
    end

    # Add a reporter to an application. If a block is given, it
    # will be yielded later (since reporters are initialized lazily)
    # with the instance of the reporter.
    #
    # @param [Class] klass A {Reporter} class.
    def reporter(klass, &block)
      @reporters << LazyReporter.new(klass, &block)
    end
  end

  class Config
    # Used internally to represent a lazily loaded reporter instance
    # for a given application.
    class LazyReporter
      # @param [Class] klass A {Reporter} class.
      def initialize(klass, &block)
        @klass = klass
        @block = block
      end

      # Returns the instance of the reporter, instantiating it on
      # demand but only once, and calling the block if specified
      # when the lazy reporter was instantiated.
      #
      # @return [Reporter]
      def instance
        @_instance ||= begin
          instance = @klass.new
          @block.call(instance) if @block
          instance
        end
      end
    end
  end
end
