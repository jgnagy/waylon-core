# frozen_string_literal: true

require "waylon/rspec/matchers/route_matcher"

module Waylon
  module RSpec
    # Extras for RSpec to facilitate testing Waylon Skills
    class TestSense < Sense
      features :reactions

      def self.add_user_from_details(details)
        user_id = user_list.size
        user = user_class.new(user_id, details)
        user_list << user
        user
      end

      # The list of TestChannel IDs for this TestSense
      # @return [Array<Integer>]
      def self.channel_list
        @channel_list ||= []
      end

      # Overrides the Sense.enqueue class method to avoid Resque
      def self.enqueue(route, request_id, body)
        details = {
          "sense" => self,
          "message" => request_id,
          "tokens" => route.tokens(body.strip)
        }

        fake_queue.push [route.destination, route.action, details]
      end

      # Allows access to the fake version of Resque
      # @return [Queue]
      def self.fake_queue
        @fake_queue ||= Queue.new
      end

      # Ensures we're using the TestMessage class for Messages
      # @return [Class]
      def self.message_class
        RSpec::TestMessage
      end

      # The list of message details that were sent through this Sense
      # @return [Array<Hash>]
      def self.message_list
        @message_list ||= []
      end

      # Receives incoming message details and places work on a queue to be performed by a Skill
      # @param message_details [Hash] The details necessary for creating a TestMessage
      # @return [void]
      def self.process(message_details)
        message_list << message_details
        message_id = message_list.size - 1
        msg = message_class.new(message_id)
        route = SkillRegistry.instance.route(msg) || SkillRegistry.instance.default_route
        enqueue(route, msg.id, msg.text)
      end

      # Emulates reactions by sending a message with the reaction type
      # @param request [Integer] A reference (message ID) of the initial request
      # @param type [Symbol,String] The type of reaction to send
      # @return [void]
      def self.react(request, type)
        msg = message_class.new(request)
        msg.channel.post_message(":#{type}:")
      end

      # Provides all message text sent _to_ Waylon
      # @return [Array<String>]
      def self.received_messages
        message_list.reject { |m| m[:user_id] == TestUser.whoami.id }.map { |m| m[:text] }
      end

      # Posts a reply to the channel
      # @param request [Integer] A reference (message ID) of the initial request
      # @param text [String] The message content to send in response to the request
      # @return [void]
      def self.reply(request, text)
        msg = message_class.new(request)
        msg.channel.post_message(text)
      end

      # Provides all message text sent _by_ Waylon
      # @return [Array<String>]
      def self.sent_messages
        message_list.select { |m| m[:user_id] == TestUser.whoami.id }.map { |m| m[:text] }
      end

      # Ensures we're using the TestUser class for Users
      # @return [Class]
      def self.user_class
        RSpec::TestUser
      end

      # The list of Users for this TestSense
      # @return [Array<User>]
      def self.user_list
        @user_list ||= []
      end

      # Automatically informs Waylon about this Sense
      SenseRegistry.register(:test, self)
    end
  end
end
