# frozen_string_literal: true

module Waylon
  module RSpec
    # The TestChannel
    class TestChannel
      attr_reader :id

      # Simple way to list all TestChannels
      # @return [Array<TestChannel>]
      def self.all
        TestSense.channel_list.each_index.map { |id| new(id) }
      end

      # Always provides a TestChannel, either by finding an existing or creating a new one
      # @return [TestChannel]
      def self.find_or_create(name)
        existing_channel = find_by_name(name)
        if existing_channel
          existing_channel
        else
          channel_details = { name:, created_at: Time.now }
          TestSense.channel_list << channel_details
          new(TestSense.channel_list.size - 1)
        end
      end

      # Looks up an existing TestChannel by name
      # @return [TestChannel,nil]
      def self.find_by_name(name)
        channel_id = TestSense.channel_list.index { |channel| channel[:name] == name }
        channel_id ? new(channel_id) : nil
      end

      # @param channel_id [Integer] The Channel ID for the new TestChannel
      # @param details [Hash] Details (namely 'name' and 'created_at') for the new TestChannel
      def initialize(channel_id, details = {})
        @id = channel_id.to_i
        @details = details
      end

      # Easy access to when the TestChannel was created
      # @return [Time]
      def created_at
        details[:created_at]
      end

      # The name of the TestChannel
      # @return [String]
      def name
        details[:name]
      end

      # Send a TestMessage to a TestChannel
      # @param content [String,Message] The Message to send
      # @return [Message] The sent Message object
      def post_message(content, from: TestUser.whoami)
        msg = if content.is_a?(Message)
                content.text
              else
                content
              end
        msg_details = {
          user_id: from.id,
          text: msg,
          type: :channel,
          channel_id: id,
          created_at: Time.now
        }
        TestSense.message_list << msg_details
        TestMessage.new(TestSense.message_list.size - 1)
      end

      # Lazily provides the details for a TestUser
      # @api private
      # @return [Hash] details for this instance
      def details
        @details = TestSense.room_list[id] if @details.empty?
        @details.dup
      end
    end
  end
end
