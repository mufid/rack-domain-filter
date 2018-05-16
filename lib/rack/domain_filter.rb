Dir["#{File.dirname(__FILE__)}/domain_filter/ext/*.rb"].sort.each do |path|
  require "rack/domain_filter/ext/#{File.basename(path, '.rb')}"
end

module Rack
  class DomainFilter
    def initialize(app, options={})
      @app = app
      @config = options[:config] || DomainFilter.global_configuration
      @match_found = false
    end

    def wrap_call
      result = yield

      run_after_request

      result
    end

    def call(env)
      if can_skip_path?(env)
        return wrap_call { @app.call(env) }
      end

      match_uri(env)

      if !@match_found && can_respond_no_match?
        return wrap_call { trigger_no_match(env) }
      end

      wrap_call { @app.call(env) }
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
  end
end
