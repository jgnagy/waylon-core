# frozen_string_literal: true

module Waylon
  # Registry of Webhook subclasses known to Waylon
  class WebhookRegistry
    include Singleton

    attr_reader :webhooks

    # A convenience wrapper around the singleton instance #register method
    # @param (see #register)
    # @return (see #register)
    def self.register(name, class_name)
      instance.register(name, class_name)
    end

    # Add the provided Webhook class to the registry under `name`
    # @param name [String] The name of the Webhook in the registry
    # @param class_name [Class] The Webhook subclass to add
    # @return [Class] The Webhook subclass
    def register(name, class_name)
      @webhooks ||= {}
      @webhooks[name.to_s] = class_name
    end

    # Provides a Hash version of this registry
    # @return [Hash]
    def to_hash
      (@webhooks || {}).transform_keys { |k| "/hooks/#{k}" }
    end
  end
end
