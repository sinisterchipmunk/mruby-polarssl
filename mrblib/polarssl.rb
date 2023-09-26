if Object.const_defined? :PolarSSL
  module PolarSSL
    VERSION = '0.0.1'

    class << self
      def debug_threshold; @debug_threshold || 0; end

      def debug(&block)
        if block_given?
          @debug = block
        else
          @debug ||= Proc.new { |level, file, line, msg| puts "#{level}: #{file}:#{line}: #{msg}" }
        end
      end

      def debug_message(*)
        debug.call(*)
      end
    end

    class MallocFailed < StandardError; end
    class NetWantRead < StandardError; end
    class NetWantWrite < StandardError; end
    class SSL
      class Error < StandardError; end
      class ReadTimeoutError < StandardError; end
      attr_reader :socket
    end
  end
end
