# frozen_string_literal: true

module Waylon
  module Conditions
    # A pre-made catch-all condition for denying access
    class PermissionDenied < Condition
      # Overrides normal Condition initialization to force a specific action
      def initialize(*_args) # rubocop:disable Lint/MissingSuper
        @mechanism = nil
        @action = :denied
        @allowed_groups = [:everyone]
        @help = "This action is not allowed"
      end

      # Matches any input (since the PermissionDenied route, when used, should always function)
      # @return [Boolean]
      def matches?(_input)
        true
      end

      # Permits any user (since the PermissionDenied route, when used, should always function)
      # @return [Boolean]
      def permits?(_user)
        true
      end

      # Just provides back all input as a single token
      # @return [Array<String>]
      def tokens(input)
        [input]
      end
    end
  end
end
