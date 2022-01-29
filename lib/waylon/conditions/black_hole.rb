# frozen_string_literal: true

module Waylon
  module Conditions
    # A pre-made catch-all condition for ignoring messages
    class BlackHole < Condition
      # Overrides normal Condition initialization to force a specific action
      def initialize(*_args) # rubocop:disable Lint/MissingSuper
        @mechanism = nil
        @action = :ignore
        @allowed_groups = [:everyone]
        @help = ""
      end

      # Matches any input (since the Default route, when used, should always function)
      # @return [Boolean]
      def matches?(_input)
        true
      end

      # Permits any user (since the Default route, when used, should always function)
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
