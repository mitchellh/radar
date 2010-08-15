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
    def reporter(klass)
      instance = klass.new
      yield instance if block_given?
      @reporters << instance
    end
  end
end
