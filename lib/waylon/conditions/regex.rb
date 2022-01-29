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

      def named_tokens(input)
        match_data = @mechanism.match(input)
        match_data.names.to_h { |n| [n.to_sym, match_data[n]] }
      end
    end
  end
end
