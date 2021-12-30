# frozen_string_literal: true

module Waylon
  module Conditions
    # Routing via Regular Expression
    class Regex < Condition
      # Checks if this condition matches the message
      # @param message [String] The message text
      # @return [Boolean]
      def matches?(message)
        @mechanism =~ message
      end

      # Provides the regular expression match groups as tokens
      # @param input [String] The message text
      # @return [Array<String>] The regular expression match groups
      def tokens(input)
        @mechanism.match(input).to_a[1..]
      end
    end
  end
end
