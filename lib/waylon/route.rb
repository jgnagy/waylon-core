# frozen_string_literal: true

module Waylon
  # A Route is a way of connecting a Sense to the right Skill, allowing for things like
  # permissions, prioritization, and scopes.
  class Route
    extend Forwardable

    attr_reader :name, :destination, :condition, :priority

    # @param name [String] The name of this route (for use in logging and exceptions)
    # @param destination [Class] The Skill subclass to send matching requests to
    # @param condition [Condition] The Condition used to see if this Route matches a request
    # @param priority [Integer] The priority value (for resolving conflicts). Highest value wins.
    def initialize(name:, destination:, condition:, priority: 10)
      validate_name(name)
      validate_destination(destination)
      validate_condition(condition)
      validate_priority(priority)
      @name = name
      @destination = destination
      @condition = condition
      @priority = priority
    end

    delegate %i[action help matches? mention_only? named_tokens permits? properly_mentions? tokens] => :@condition

    private

    # Validates the Condition
    # @param condition [Condition]
    # @raise [Exceptions::ValidationError]
    # @return [Boolean]
    def validate_condition(condition)
      raise Exceptions::ValidationError, "Route condition must be a Condition" unless condition.is_a?(Condition)

      true
    end

    # Validates the destination
    # @param destination [Class]
    # @raise [Exceptions::ValidationError]
    # @return [Boolean]
    def validate_destination(destination)
      unless destination.ancestors.include?(Skill)
        raise Exceptions::ValidationError, "Route destination must be a Skill"
      end

      true
    end

    # Validates the Route name
    # @param name [String]
    # @raise [Exceptions::ValidationError]
    # @return [Boolean]
    def validate_name(name)
      raise Exceptions::ValidationError, "Route name must be a String" unless name.is_a?(String)
      raise Exceptions::ValidationError, "Route name must not be empty" if name.empty?

      true
    end

    # Validates the priority
    # @param priority [Integer]
    # @raise [Exceptions::ValidationError]
    # @return [Boolean]
    def validate_priority(priority)
      raise Exceptions::ValidationError, "Route priority must be between 0 and 99" unless (0..99).include?(priority)
    end
  end
end
