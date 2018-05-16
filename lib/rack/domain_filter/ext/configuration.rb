module Rack
  class DomainFilter

    module ConfigurationDSL
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

      def skip_path_for(pattern)
        @skip_path_patterns << pattern
      end
    end

    # private
    class Configuration

      attr_accessor :uri_mapping
      attr_accessor :after_requests_list
      attr_accessor :exception_catcher_mapping
      attr_accessor :skip_path_patterns

      def initialize
        @uri_mapping = {}
        @after_requests_list = []
        @exception_catcher_mapping = {}
        @no_match = nil
        @skip_path_patterns = []
      end

      include ConfigurationDSL

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
