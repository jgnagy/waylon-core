# frozen_string_literal: true

module Waylon
  # A simple way to abstract logging
  module Logger
    # The log level as defined in the global Config singleton
    # @return [String] The current log level
    def self.level
      Config.instance["global.log.level"]
    end

    # Abstraction for sending logs to the logger at some level
    # @param [Symbol] level The log level this message corresponds to
    # @param [String] message The message to log at this specified level
    def self.log(message, level = :info)
      logger.send(level, message)
    end

    # Provides an easy way to access the underlying logger
    # @return [Logger] The Logger instance
    def self.logger
      return @logger if @logger

      @logger = ::Logger.new($stderr)
      @logger.level = level
      @logger.progname = "Waylon"
      @logger.formatter = proc do |severity, datetime, progname, msg|
        json_data = JSON.dump(
          ts: datetime,
          severity: severity.ljust(5).to_s,
          progname: progname,
          pid: Process.pid,
          message: msg,
          v: Waylon::Core::VERSION
        )
        "#{json_data}\n"
      end
      @logger
    end
  end
end
