# frozen_string_literal: true

module Waylon
  module RSpec
    # A test Message class
    class TestMessage
      include Waylon::Message

      attr_reader :id

      # Simple way to list all TestMessages
      # @return [Array<TestMessage>]
      def self.all
        TestSense.message_list.each_index.map { |id| new(id) }
      end

      # @param message_id [Integer] The Message ID for the new TestMessage
      # @param details [Hash] Details hash for the new TestMessage
      def initialize(message_id, details = {})
        @id = message_id.to_i
        @details = details
      end

      # Provides the user that authored the message
      # @return [TestUser]
      def author
        TestUser.new(details[:user_id])
      end

      # Easy access to when the TestMessage was created
      # @return [Time]
      def created_at
        details[:created_at]
      end

      # Is this a private message?
      # @return [Boolean]
      def private_message?
        details[:type] == :private
      end

      # The TestChannel where this TestMessage lives
      # @return [TestChannel]
      def channel
        TestChannel.new(details[:channel_id])
      end

      # The Message content
      # @return [String]
      def text
        details[:text]
      end

      alias body text

      # Lazily provides the details for TestMessages
      # @api private
      # @return [Hash] The details for this TestMessage instance
      def details
        @details = TestSense.message_list[id] if @details.empty?
        @details.dup
      end
    end
  end
end
