require 'radar/version'
require 'radar/error'

module Radar
  autoload :Application,    'radar/application'
  autoload :Config,         'radar/config'
  autoload :ExceptionEvent, 'radar/exception_event'
  autoload :Logger,         'radar/logger'
  autoload :Reporter,       'radar/reporter'
  autoload :Support,        'radar/support'

  module DataExtensions
    autoload :HostEnvironment, 'radar/data_extensions/host_environment'
    autoload :Rack, 'radar/data_extensions/rack'
  end

  module Integration
    autoload :Rack,   'radar/integration/rack'
    autoload :Rails3, 'radar/integration/rails3'
  end

  module Matchers
    autoload :BacktraceMatcher, 'radar/matchers/backtrace_matcher'
    autoload :ClassMatcher,     'radar/matchers/class_matcher'
  end

  class Reporter
    autoload :FileReporter, 'radar/reporter/file_reporter'
    autoload :IoReporter,   'radar/reporter/io_reporter'
  end
end

module Rack
  autoload :Radar, 'radar/integration/rack'
end
