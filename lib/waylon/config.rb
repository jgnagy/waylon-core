# frozen_string_literal: true

module Waylon
  # The global configuration
  class Config
    include Singleton
    extend Forwardable

    attr_accessor :schema

    delegate delete: :@config

    # Stores schema metadata about config items
    # @api private
    # @param key [String] The config key to define a schema for
    # @param required [Boolean] Is this key required on startup?
    # @param type [Class] The class type for the stored value
    # @param default [Object] The optional default value
    # @return [Boolean] Was the schema update successful?
    def add_schema(key, default: nil, required: false, type: String)
      @schema ||= {}
      @schema[key] = { default: default, required: required, type: type }
      true
    end

    # A list of emails specified via the CONF_GLOBAL_ADMINS environment variable
    # @return [Array<String>] a list of emails
    def admins
      admin_emails = self["global.admins"]
      admin_emails ? admin_emails.split(",") : []
    end

    # Load in the config from env variables
    # @return [Boolean] Was the configuration loaded?
    def load_env
      @schema ||= {}
      self["global.log.level"] = ENV.fetch("LOG_LEVEL", "info")
      self["global.redis.host"] = ENV.fetch("REDIS_HOST", "redis")
      self["global.redis.port"] = ENV.fetch("REDIS_PORT", "6379")
      ENV.keys.grep(/CONF_/).each do |env_key|
        conf_key = env_key.downcase.split("_")[1..].join(".")
        ::Waylon::Logger.log("Attempting to set #{conf_key} from #{env_key}", :debug)
        self[conf_key] = ENV[env_key]
      end
      true
    end

    # Provides the redis host used for most of Waylon's brain
    # @return [String] The redis host
    def redis_host
      self["global.redis.host"]
    end

    # Provides the redis port used for most of Waylon's brain
    # @return [String] The redis host
    def redis_port
      self["global.redis.port"]
    end

    # Clear the configuration
    # @return [Boolean] Was the configuration reset?
    def reset
      @config = {}
      true
    end

    # Check if a given key is explicitly set (not including defaults)
    # @param key [String] The key to check
    # @return [Boolean] Is the key set?
    def key?(key)
      @config ||= {}
      @config.key?(key)
    end

    alias set? key?

    # Check if a given key is has _any_ value (default or otherwise)
    # @param key [String] The key to look for
    # @return [Boolean] Does the key have a value?
    def value?(key)
      @config ||= {}
      !self[key].nil?
    end

    # Set the value for a key
    # @param key [String] The key to use for storing the value
    # @param [Object] value The value for the key
    def []=(key, value)
      if (@schema[key] && validate_config(@schema[key], value)) || key.start_with?("global.")
        @config ||= {}
        @config[key] = value
      elsif @schema[key]
        ::Waylon::Logger.log("Ignoring invalid config value for key: #{key}", :warn)
      else
        ::Waylon::Logger.log("Ignoring unknown config key: #{key}", :warn)
      end
    end

    # Retrieve the value for the given key
    # @param key [String] The key to lookup
    # @return [String,nil] The requested value
    def [](key)
      @config ||= {}
      if @config.key?(key)
        @config[key].dup
      elsif @schema.key?(key) && @schema[key][:default]
        @schema[key][:default].dup
      end
    end

    # Is the state of the config valid?
    # @return [Boolean]
    def valid?
      missing = @schema.select { |_k, v| v[:required] }.reject { |k, _v| @config[k] }
      missing.each do |key, _value|
        ::Waylon::Logger.log("Missing config: #{key}", :debug)
      end
      missing.empty?
    end

    # Checks if a value aligns with a schema
    # @param schema [Hash] The schema definition for this value
    # @param value The value to compare to the schema
    # @return [Boolean]
    def validate_config(schema, value)
      type = schema[:type]
      if type == :boolean
        value.is_a?(TrueClass) || value.is_a?(FalseClass)
      else
        value.is_a?(type)
      end
    end
  end
end
