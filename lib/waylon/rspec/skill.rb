# frozen_string_literal: true

require "waylon/rspec/matchers/route_matcher"

module Waylon
  module RSpec
    # Extras for RSpec to facilitate testing Waylon Skills
    module Skill
      include Matchers::RouteMatcher

      class << self
        # Sets up the RSpec environment
        def included(base)
          base.send(:include, Waylon::RSpec)

          init_let_blocks(base)
          init_subject(base)
        end

        private

        # Create common test objects.
        def init_let_blocks(base)
          base.class_eval do
            let(:bot) { TestUser.new(0) }
            let(:testuser) { TestUser.new(1) }
            let(:chatroom) { TestChannel.new(0) }
            let(:adminuser) do
              @adminuser ||= TestUser.find_or_create(name: "Charles Montgomery Burns", handle: "monty")
              Group.new("admins").add(@adminuser)
              @adminuser
            end
          end
        end

        # Set up a working test subject.
        def init_subject(base)
          base.class_eval do
            subject { described_class }
          end
        end
      end

      # An array of strings that have been sent by the bot during throughout a test
      # @return [Array<String>] The replies.
      def replies
        TestSense.sent_messages
      end

      # Sends a message to the bot
      # @param body [String] The message to send
      # @param from [TestUser] The user sending the message
      # @param channel [TestChannel] Where the message is received
      # @param privately [Boolean] Is the message a DM
      # @return [void]
      def send_message(body, from: testuser, channel: nil, privately: false)
        msg_details = { person_id: from.id, text: body, created_at: Time.now }
        if privately
          msg_details[:type] = :private
          msg_details[:receiver_id] = robot.id
        else
          msg_details[:type] = :channel
          msg_details[:channel_id] = channel ? channel.id : chatroom.id
        end

        TestSense.perform(msg_details)
        TestWorker.handle(TestSense.fake_queue)
      end
    end
  end
end
