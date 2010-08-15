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
end
