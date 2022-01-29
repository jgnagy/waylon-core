# frozen_string_literal: true

module Waylon
  # Registry of Sense subclasses known to Waylon
  class SenseRegistry
    include Singleton

    attr_reader :senses

    # A convenience wrapper around the singleton instance #register method
    # @param (see #register)
    # @return (see #register)
    def self.register(name, class_name)
      instance.register(name, class_name)
    end

    # Add the provided Sense class to the registry under `name`
    # @param name [String] The name of the Sense in the registry
    # @param class_name [Class] The Sense subclass to add
    # @return [Class] The Sense subclass
    def register(name, class_name)
      @senses ||= {}
      @senses[name.to_s] = class_name
    end

    # Provides a Hash version of this registry
    # @return [Hash]
    def to_hash
      (@senses || {}).dup
    end
  end
end
