require 'radar/version'
require 'radar/error'

module Radar
  autoload :Application,    'radar/application'
  autoload :Config,         'radar/config'
  autoload :ExceptionEvent, 'radar/exception_event'
  autoload :Reporter,       'radar/reporter'
end
