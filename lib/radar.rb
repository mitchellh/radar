require 'radar/version'
require 'radar/error'

module Radar
  autoload :Application,    'radar/application'
  autoload :Config,         'radar/config'
  autoload :ExceptionEvent, 'radar/exception_event'
  autoload :Reporter,       'radar/reporter'
  autoload :Support,        'radar/support'

  module DataExtensions
    autoload :HostEnvironment, 'radar/data_extensions/host_environment'
  end
end
