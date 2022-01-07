# frozen_string_literal: true

module Waylon
  # The base mixin for all core Waylon components
  # @abstract
  module BaseComponent
    def self.included(base)
      base.send :include, InstanceLoggingMethods
      base.send :include, InstanceUtilityMethods
      base.extend ClassLoggingMethods
      base.extend ClassUtilityMethods
    end

    # Base class logging methods
    module ClassLoggingMethods
      # Simple pass-through for logging through the Waylon Logger
      # @param message [String] The message to log
      # @param level [String,Symbol] The log level for this message
      def log(message, level = :info)
        ::Waylon::Logger.log(message, level)
      end
    end

    # Base Component utility methods
    module ClassUtilityMethods
      # Allows caching from class methods
      # @param [String] key How to store/retrieved the cached value
      # @param [Integer] expires How long to cache the value
      def cache(key, expires: 600)
        cache_key = config_key_for(key)
        if !Waylon::Cache.key?(cache_key) && block_given?
          result = yield
          Waylon::Cache.store(cache_key, result, expires: expires)
        elsif !Waylon::Cache.key?(cache_key)
          return nil
        end
        Waylon::Cache.load(cache_key, expires: expires)
      end

      # The namespace used for this component's storage
      # @param value [String,nil] Sets this namespace unless set (without setting, returns a sane default)
      # @return [String] The namespace for this component
      def component_namespace(value = nil)
        @namespace ||= value
        # Either returns the namespace or the stripped down class name
        @namespace || name.to_s.split("::").last.downcase
      end

      # Creates namespaced configuration keys for Webhook subclasses
      # @param (see Config#add_schema)
      def config(key, default: nil, required: false, type: String)
        conf = Config.instance
        config_key = config_key_for(key)
        conf.add_schema(config_key, default: default, required: required, type: type)
      end

      # Provides the full Config key given a relative key
      # @param key [String] The relative key to fully-qualify
      # @return [String] The fully-qualified Config key
      def config_key_for(key)
        "#{config_namespace}.#{key}"
      end

      # Determines if the current component is fully configured
      # @return [Boolean]
      def configured?
        conf = Config.instance
        req_confs = conf.schema.select do |k, v|
          k.match?(/^#{config_namespace}\./) && v[:required]
        end
        missing_configs = req_confs.reject { |k, _v| conf.set?(k) }
        if missing_configs.empty? && conf.valid?
          true
        elsif missing_configs.empty?
          log("Configuration for #{component_namespace} failed validation!", :error)
          false
        else
          missing_configs.each { |k, _v| log("Missing required configuration: #{k}", :error) }
          false
        end
      end

      # Describes features supported by a Sense
      # @param list [String,Array<String,Symbol>] List of features supported by this BaseComponent
      def features(list)
        @features = [*list].map(&:to_sym)
      end

      # Determine if a BaseComponent subclass supports a feature
      # @param key [String,Symbol] The feature in question
      def supports?(key)
        @features ||= []
        @features.include?(key.to_sym)
      end
    end

    # Base instance logging methods
    module InstanceLoggingMethods
      # Instance-level access to logging via the Class log method
      # @param (see ClassLoggingMethods#log)
      def log(message, level = :info)
        self.class.log(message, level)
      end
    end

    # Base instance utility methods
    module InstanceUtilityMethods
      # Allows caching operations (or retrieving cached versions)
      # @param [String] key How to store/retrieved the cached value
      # @param [Integer] expires How long to cache the value
      def cache(key, expires: 600)
        cache_key = self.class.config_key_for(key)
        if !Waylon::Cache.key?(cache_key) && block_given?
          result = yield
          Waylon::Cache.store(cache_key, result, expires: expires)
        elsif !Waylon::Cache.key?(cache_key)
          return nil
        end
        Waylon::Cache.load(cache_key, expires: expires)
      end

      # A wrapper for access to a namespaced Config key
      # @param [String] key The key name to lookup
      def config(key)
        conf = Config.instance
        conf[self.class.config_key_for(key)]
      end

      # A wrapper for accessing the persistent storage
      # @return [Waylon::Storage] The Storage wrapper class
      def storage
        Waylon::Storage
      end

      alias db storage
    end
  end
end
