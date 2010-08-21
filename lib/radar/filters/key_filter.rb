module Radar
  module Filters
    # Filters the event data by filtering out a given key which
    # can exist anywhere in the data hash. For example, given
    # the following hash:
    #
    #     { :request  => { :password => "foo" },
    #       :rack_env => { :params => { :password => "foo" } } }
    #
    # If the KeyFilter was configured like so:
    #
    #     app.filters.use :key, :key => :password
    #
    # Then the data hash would turn into:
    #
    #     { :request  => { :password => "[FILTERED]" },
    #       :rack_env => { :params => { :password => "[FILTERED]" } } }
    #
    # ## Options
    #
    # * `:key` - A single element or array of elements which represent the
    #   keys to filter out of the event hash.
    # * `:filter_text` - The text which replaces keys which are caught by the
    #   filter. This defaults to "[FILTERED]"
    #
    class KeyFilter
      attr_accessor :key
      attr_accessor :filter_text

      def initialize(opts=nil)
        (opts || {}).each do |k,v|
          send("#{k}=", v)
        end

        @filter_text ||= "[FILTERED]"
      end

      def filter(data)
        # Convert the keys to strings, since we always compare against strings
        filter_keys = [key].flatten.collect { |k| k.to_s }

        data.each do |k,v|
          if filter_keys.include?(k.to_s)
            data[k] = filter_text
          elsif v.is_a?(Hash)
            filter(v)
          end
        end

        data
      end
    end
  end
end
