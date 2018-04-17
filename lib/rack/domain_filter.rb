module Rack
  class DomainFilter

    module ExceptionHandler
      def catch_exception(e)
        config.exception_catcher_mapping.each_pair do |klazz, block|
          if e.is_a?(klazz)
            return block.call(e)
          end
        end

        raise e
      end
    end

    module AfterRequestHandler
      def run_after_request
        config.after_requests_list.each do |block|
          block.call
        end
      end
    end

    module Matcher
      # See https://www.youtube.com/watch?v=b77V0rkr5rk
      # Use host_with_port for better performance
      # See: https://github.com/rack/rack/blob/master/lib/rack/request.rb
      def match_uri(env)
        req = Rack::Request.new(env)
        config.uri_mapping.each_pair do |pattern, block|
          if pattern.is_a?(String)
            break if match_string(pattern, req, block)
          elsif pattern.is_a?(Regexp)
            break if match_regex(pattern, req, block)
          else
            raise "Unknown pattern: #{pattern}. It must be a regex or a string!"
          end
        end
      end

      def can_respond_no_match?
        !config.no_match_block.nil?
      end

      def trigger_no_match(env)
        config.no_match_block.call(env)
      end

      def match_regex(regex, req, block)
        matchdata = req.host_with_port.match(regex)
        return if matchdata.nil?

        block.call(matchdata[1], req.env)

        @match_found = true

        true
      end

      def match_string(string, req, block)
        return if string != req.host_with_port

        block.call(req.env)

        @match_found = true

        true
      end
    end

    def initialize(app, options={})
      @app = app
      @config = options[:config] || DomainFilter.global_configuration
    end

    def call(env)
      match_uri(env)

      if !@match_found && can_respond_no_match?
        result = trigger_no_match(env)
        run_after_request
        return result
      end

      result = @app.call(env)

      run_after_request

      result
    rescue => e
      result = catch_exception(e)
      run_after_request

      result
    end

    include ExceptionHandler
    include AfterRequestHandler
    include Matcher

    def self.configure
      @global_configuration ||= Configuration.new

      yield @global_configuration
    end

    def self.clear_configuration!
      @global_configuration = nil
    end

    def self.global_configuration
      @global_configuration
    end

    def config
      @config
    end
    def verify_configuration!

    end

    class Configuration

      attr_accessor :uri_mapping
      attr_accessor :after_requests_list
      attr_accessor :exception_catcher_mapping

      def initialize
        @uri_mapping = {}
        @after_requests_list = []
        @exception_catcher_mapping = {}
      end

      def filter_for(pattern, &block)
        @uri_mapping[pattern] = block
      end

      def after_request(&block)
        @after_requests_list << block
      end

      def catch(klazz, &block)
        @exception_catcher_mapping[klazz] = block
      end

      def no_match(&block)
        raise 'Only allowed 1 no_match block!' if !@no_match.nil?

        @no_match = block
      end

      def no_match_block
        @no_match
      end

      def allow_passthrough
        @allow_passthrough = true
      end

      def allow_passthrough?
        @allow_passthrough
      end
    end
  end
end
