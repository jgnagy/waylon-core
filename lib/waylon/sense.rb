# frozen_string_literal: true

module Waylon
  # Base class for Senses (Usually messaging providers like Slack)
  class Sense
    include BaseComponent

    # Almost always meant to be overridden, this is how the Sense wraps text in a code block
    # @param text [String] The string to codify
    # @return [String] Properly wrapped content
    def self.codify(text)
      "```\n#{text}```"
    end

    # Config namespace for config keys
    # @return [String] The namespace for config keys
    def self.config_namespace
      "senses.#{component_namespace}"
    end

    # The connection between Senses and Skills happens here, via a Route and a Hash of details
    # @param route [Route] route The matching Route from the SkillRegistry
    # @param request_id [String] The ID (from the messaging platform) of the request
    # @param body [String] Message content for the Skill
    # @api private
    def self.enqueue(route, request_id, body)
      details = {
        "sense" => self,
        "message" => request_id,
        "tokens" => route.tokens(body.strip)
      }

      Resque.enqueue route.destination, route.action, details
    end

    # Provides a simple mechanism for referencing the Group subclass provided by this Sense
    # @return [Class] A Group subclass
    def self.group_class
      Group
    end

    # "At-mention" a User via the Sense. This is usually overridden on Sense subclasses.
    # @param user [Waylon::User] The User to mention
    # @return [String]
    def self.mention(user)
      "@#{user.handle}"
    end

    # Provides a simple mechanism for referencing the Message subclass provided by this Sense
    # @return [Class] A Message subclass
    def self.message_class
      Message
    end

    # Called by Resque to actually use this BaseComponent. Hands off to run() method
    # @param content [Hash] The payload hash for use in processing the message
    def self.perform(content)
      run(content)
    end

    # Redis/Resque queue name
    # @api private
    # @return [Symbol]
    def self.queue
      :senses
    end

    # Provides a simple mechanism for referencing the User subclass provided by this Sense
    # @return [Class] A User subclass
    def self.user_class
      User
    end
  end
end
