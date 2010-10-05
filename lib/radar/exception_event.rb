require 'digest/sha1'
require 'json'

module Radar
  # Represents the event of an exception being captured. This class
  # contains references to the {Application} and exception which is
  # raised.
  class ExceptionEvent
    attr_reader :application
    attr_reader :exception
    attr_reader :backtrace
    attr_reader :extra
    attr_reader :occurred_at

    def initialize(application, exception, extra=nil)
      @application = application
      @exception   = exception
      @backtrace   = Backtrace.new(exception.backtrace)
      @extra       = extra || {}
      @occurred_at = Time.now
    end

    # Checks if this event matches the given matcher. This can be a
    # class or symbol representing the matcher. If a block is given, without
    # any matcher specified, then that proc will be used as the matcher. If
    # a class is given, in addition to a block, then the block will be passed
    # to the initializer of the matcher class.
    #
    # @return [Boolean]
    def match?(*args, &block)
      c = Config.new
      c.match(*args, &block)
      c.matchers.values.first.call(self)
    end

    # A hash of information about this exception event. This includes
    # {Application#to_hash} as well as information about the exception.
    # This also includes any {Config#data_extensions data_extensions} if
    # specified.
    #
    # @return [Hash]
    def to_hash
      return @_to_hash_result if @_to_hash_result

      result = { :application => application.to_hash,
        :exception => {
          :klass => exception.class.to_s,
          :message => exception.message,
          :backtrace => backtrace,
          :uniqueness_hash => uniqueness_hash
        },
        :occurred_at => occurred_at.to_i
      }

      application.config.data_extensions.values.each do |extension|
        Support::Hash.deep_merge!(result, extension.new(self).to_hash || {})
      end

      application.config.filters.values.each do |filter|
        result = filter.call(result)
      end

      # Cache the resulting hash to it is only generated once.
      @_to_hash_result = result
      result
    end

    # JSONified {#to_hash} output.
    #
    # @return [String]
    def to_json
      to_hash.to_json
    end

    # Returns uniqueness hash to test if one event is roughly equivalent to
    # another. The uniqueness hash is generated by taking the exception
    # backtrace and class and generating the SHA1 hash of those concatenated.
    #
    # @return [String]
    def uniqueness_hash
      Digest::SHA1.hexdigest("#{exception.class}-#{exception.backtrace rescue 'blank'}")
    end
  end
end
