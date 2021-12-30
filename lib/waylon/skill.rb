# frozen_string_literal: true

module Waylon
  # Skills are what Waylon can do based on inputs from Senses
  class Skill
    include BaseComponent

    attr_reader :sense, :tokens, :request

    # Config namespace for config keys
    # @return [String] The namespace for config keys
    def self.config_namespace
      "skills.#{component_namespace}"
    end

    # Resque uses this to execute the Skill. Just defers to the `action` subclass method
    # @param action [Symbol,String] The method on the Skill subclass to call
    # @param details [Hash] Input details about the message for running a Skill action
    def self.perform(action, details)
      new(details["sense"], details["tokens"], details["message"], details["meta"])
        .send(action.to_sym)
    end

    # Redis/Resque queue name
    # @api private
    # @return [Symbol]
    def self.queue
      :senses
    end

    # Adds skills to the SkillRegistry
    # @param condition [Condition,Regexp] The condition that determines if this route applies
    # @param action [Symbol,String] The method on the Skill subclass to call
    # @param allowed_groups [Symbol,Array<Symbol>] The group or list of groups allowed to use this
    # @param help [String] A description of how to use the skill
    def self.route(condition, action, allowed_groups: :everyone, help: nil, name: nil)
      name ||= "#{to_s.split("::").last.downcase}##{action}"
      real_cond = case condition
                  when Condition
                    condition
                  when Regexp
                    Conditions::Regex.new(condition, action, allowed_groups, help)
                  else
                    log("Unknown condition for route for #{name}##{action}", :warn)
                    nil
                  end
      SkillRegistry.instance.register(name, self, real_cond) if real_cond
    end

    # @param sense [Class,String] Class (or Class name) of the source Sense
    # @param tokens [Array<String>] Tokenized message content for use in the Skill
    # @param request [String,Integer] Reference to the request from the Sense provider (usually an ID)
    # @param meta [Hash] Optional meta data that can be passed along from a Sense for use in Skills
    def initialize(sense, tokens, request, meta)
      @sense   = sense.is_a?(Class) ? sense : Module.const_get(sense)
      @tokens  = tokens || []
      @request = request
      @meta    = meta
    end

    # Provides a random entry from a list of canned acknowledgements
    # @return [String]
    def acknowledgement
      responses = [
        "I'll get back to you in just a sec.",
        "You got it!",
        "As you wish.",
        "Certainly!",
        "Sure thing!",
        "Absolutely!",
        "No problem.",
        "Consider it done.",
        "Of course!",
        "I'd be delighted!",
        "Right away!",
        "Gladly",
        "All right.",
        "I'm all over it.",
        "I'm on it!",
        "Let me see what I can do.",
        "Will do!"
      ]
      responses.sample
    end

    # Provides a simple way to convert some text to a code block in a way the Sense understands
    # @param text [String] The string to codify
    # @return [String] Properly wrapped content
    def codify(text)
      sense.codify(text)
    end

    # The details used to call this Skill
    # @return [Hash]
    def details
      {
        sense: @sense,
        message: @request,
        tokens: @tokens,
        meta: @meta
      }
    end

    # Defers to the Sense to determine how to mention a user
    # @param [Waylon::User] user The user to mention
    # @return [String]
    def mention(user)
      sense.mention(user)
    end

    # Provides a wrapped message for responding to the received Sense
    # @return [Waylon::Message]
    def message
      sense.message_class.new(request)
    end

    # Defers to the Sense to react to a message
    # @param [String] type The type of reaction to send
    # @return [Boolean,String]
    def react(type)
      return false unless sense.supports?(:reactions)

      sense.react(request, type)
    end

    # Defers to the Sense to determine how to reply to a message
    # @param [String] text The reply text
    def reply(text)
      sense.reply(request, text)
    end
  end
end
