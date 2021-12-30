# frozen_string_literal: true

module Waylon
  module RSpec
    # Extras for RSpec to facilitate testing Waylon (by creating fake Users)
    class TestUser
      include Waylon::User

      attr_reader :id

      # Looks up a User by their email
      # @param email [String] The User's email
      # @return [User,nil] The found User
      def self.find_by_email(email)
        TestSense.user_list.find { |user| user.email == email }
      end

      # Looks up a User by their IM handle
      # @param handle [String] The User's handle
      # @return [User,nil] The found User
      def self.find_by_handle(handle)
        TestSense.user_list.find { |user| user.handle == handle }
      end

      # Looks up a User by their full name
      # @param name [String] The User's name
      # @return [User,nil] The found User
      def self.find_by_name(name)
        TestSense.user_list.find { |user| user.display_name == name }
      end

      # Looks up existing or creates a new User based on their full name, email, or handle
      # @param name [String] The full name of the User
      # @param email [String] The User's email
      # @param handle [String] The User's handle
      # @return [User,Boolean]
      # rubocop:disable Metrics/PerceivedComplexity,Metrics/CyclomaticComplexity
      def self.find_or_create(name: nil, email: nil, handle: nil)
        return false unless name || email || handle # have to provide _something_

        existing_user = find_by_email(email) || find_by_handle(handle) || find_by_name(name)
        if existing_user
          existing_user
        else
          this_name = name || random_name # if no name was provided, make one up
          details = {
            email: email || email_from_name(this_name),
            handle: handle || handle_from_name(this_name),
            name: this_name,
            status: :online
          }
          # Need to give up if we've generated a duplicate
          if find_by_email(details[:email]) || find_by_handle(details[:handle]) || find_by_name(details[:name])
            return false
          end

          TestSense.add_user_from_details(details)
        end
      end
      # rubocop:enable Metrics/PerceivedComplexity,Metrics/CyclomaticComplexity

      # Provides a random human-sounding full name for test users
      # @return [String]
      def self.random_name
        first_names = %w[
          Abraham Al Alex Barbara Barry Bob Brenda Chloe Chuck Daniel Dave Eliza Felicia Frank
          Francis Glen Graham Greg Hal Jackie Jacob Jessica Jonathan Julie Maria Marcia Nikhil
          Olivia Patrick Paul Reggie Robby Roger Sam Saul Sean Tim Todd Tristan Xavier Zack
        ]
        last_names = %w[
          Adams Andrews Bailey Brooks Brown Bush Cervantes Chen Collins Crooks Dean Franz Harris
          Jackson Jimenez Jones Jordan Laflor Lopez Gonzalez McDowell Miller Ng Odinson Reed
          Roberts Rodriguez Sanders Schmidt Scott Smith Stewart Taylor Tesla Torres Turner
          Walker Ward Warner White Williams Wilson Wong Young Zeta Zimmerman
        ]

        "#{first_names.sample} #{last_names.sample}"
      end

      # Gives back the TestUser for the bot
      # @return [TestUser] Waylon's User instance
      def self.whoami
        find_by_email("waylon.smithers@example.com")
      end

      # @param user_id [Integer] The ID of the user in the TestSense's user list
      # @param details [Hash] Optional User details (can be looked up later)
      def initialize(user_id, details = {})
        @id = user_id.to_i
        @details = details
      end

      # The User's full name (:user from the details Hash)
      # @return [String]
      def display_name
        details[:name]
      end

      # The User's email address
      # @return [String]
      def email
        details[:email]
      end

      # Sends a direct TestMessage to a User
      # @param content [String] The message content to send
      # @return [TestMessage]
      def private_message(content)
        msg = {
          user_id: self.class.whoami.id,
          receiver_id: id,
          text: content,
          type: :private,
          created_at: Time.now
        }
        TestSense.message_list << msg
        TestMessage.new(TestSense.message_list.size - 1)
      end

      # The User's handle
      # @return [String]
      def handle
        details[:handle]
      end

      # The User's current status
      # @return [Symbol]
      def status
        details[:status]
      end

      # Is the User valid?
      # @return [Boolean]
      def valid?
        true
      end

      # Lazily provides the details for a TestUser
      # @api private
      # @return [Hash] Details for this instance
      def details
        @details = TestSense.user_list[id].details if @details.empty?
        @details.dup
      end

      # Creates an email address based on the name provided
      # @api private
      # @return [String] A generated email address
      def self.email_from_name(name)
        if ENV["USER_EMAIL"] && name == "homer.simpson"
          ENV["USER_EMAIL"]
        else
          "#{name.downcase.gsub(/[\s_-]/, ".")}@example.com"
        end
      end

      # Creates a handle from a name
      # @api private
      # @return [String] A generated user handle
      def self.handle_from_name(name)
        name.downcase.split(/[\s_-]/).first
      end
    end
  end
end
