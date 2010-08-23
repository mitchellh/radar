require 'radar/version'
require 'radar/error'
require 'radar/integration/rails3/railtie' if defined?(Rails::Railtie)

module Radar
  autoload :Application,    'radar/application'
  autoload :Backtrace,      'radar/backtrace'
  autoload :Config,         'radar/config'
  autoload :ExceptionEvent, 'radar/exception_event'
  autoload :Logger,         'radar/logger'
  autoload :Reporter,       'radar/reporter'
  autoload :Support,        'radar/support'

  module DataExtensions
    autoload :HostEnvironment, 'radar/data_extensions/host_environment'
    autoload :Rack,            'radar/data_extensions/rack'
    autoload :Rails2,          'radar/data_extensions/rails2'
  end

  module Filters
    autoload :KeyFilter, 'radar/filters/key_filter'
  end

  module Integration
    autoload :Rack,    'radar/integration/rack'
    autoload :Rails2,  'radar/integration/rails2'
    autoload :Rails3,  'radar/integration/rails3'
    autoload :Sinatra, 'radar/integration/sinatra'
  end

  module Matchers
    autoload :BacktraceMatcher, 'radar/matchers/backtrace_matcher'
    autoload :ClassMatcher,     'radar/matchers/class_matcher'
  end

  class Reporter
    autoload :FileReporter,   'radar/reporter/file_reporter'
    autoload :HoptoadReporter,'radar/reporter/hoptoad_reporter'
    autoload :IoReporter,     'radar/reporter/io_reporter'
    autoload :LoggerReporter, 'radar/reporter/logger_reporter'
  end
end

module Rack
  autoload :Radar, 'radar/integration/rack'
end
