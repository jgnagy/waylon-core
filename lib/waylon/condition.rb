# frozen_string_literal: true

module Waylon
  # Abstract route condition superclass
  # @abstract
  class Condition
    attr_reader :action, :help, :mechanism

    # @param mechanism The meat of the condition used to decide if this condition applies
    # @param action [Symbol] The method to call if the condition matches
    # @param allowed_groups [Array<Symbol>] The group names allowed to use this action
    # @param help [String] Optional help text to describe usage for this action
    # @param mention_only [Boolean] Only applies to messages that directly mention (or IM) this bot
    # rubocop:disable Style/OptionalBooleanParameter
    def initialize(mechanism, action, allowed_groups, help = nil, mention_only = true)
      @mechanism = mechanism
      @action = action
      @allowed_groups = allowed_groups
      @help = help
      @mention_only = mention_only
    end
    # rubocop:enable Style/OptionalBooleanParameter

    # Placeholder for determining if this condition applies to the given input
    # @param _input [Waylon::Message] The input message
    # @return [Boolean]
    def matches?(_input)
      false
    end

    # Is this condition only valid for Messages that directly mention the bot?
    # @return [Boolean]
    def mention_only?
      @mention_only
    end

    # Placeholder for optionally providing _named_ tokens
    # @param _input [String] The message content
    # @return [Hash<String,Object>]
    def named_tokens(_input)
      {}
    end

    # Checks if a user is allowed based on this condition
    # @param user [Waylon::User] abstract user
    def permits?(user)
      return true if allows?(:everyone)

      Logger.log("Checking permissions for #{user.email}", :debug)
      group_class = user.class.sense.group_class
      # Check for global admins
      return true if Config.instance.admins.include?(user.email)
      # Check for managed admins
      return true if group_class.new("admins").include?(user)

      permitted = false

      [*@allowed_groups].each do |group|
        permitted = true if group_class.new(group).include?(user)
        break if permitted
      end
      permitted
    end

    # Determines of a message complies with the {#mention_only?} setting for this condition
    # @param message [Waylon::Message] The received message
    # @return [Boolean]
    def properly_mentions?(message)
      (mention_only? && message.to_bot?) || (!mention_only? && !message.to_bot?)
    end

    # Tokens is used to provide details about the message input to the action
    # @param _input [String] The message content as text
    # @return [Array<String>] The tokens extracted from the input message
    def tokens(_input)
      []
    end

    private

    # Determines if a group name is among the list of allowed groups for this condition
    # @note Does not involve determining user group membership, just allows access to the list of allowed groups
    # @param group [Symbol] A group name to lookup
    def allows?(group)
      @allowed_groups ||= []
      [*@allowed_groups].include?(group.to_sym)
    end
  end
end
