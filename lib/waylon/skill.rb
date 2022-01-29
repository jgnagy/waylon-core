# frozen_string_literal: true

module Waylon
  # Skills are what Waylon can do based on inputs from Senses
  class Skill
    include BaseComponent

    attr_reader :sense, :tokens, :request, :route

    # Config namespace for config keys
    # @return [String] The namespace for config keys
    def self.config_namespace
      "skills.#{component_namespace}"
    end

    # Resque uses this to execute the Skill. Just defers to the `action` subclass method
    # @param details [Hash] Input details about the message for running a Skill action
    def self.perform(details)
      skill = new(details["sense"], details["route"], details["request"], details["meta"])
      skill.send(skill.route.action.to_sym)
    end

    # Redis/Resque queue name
    # @api private
    # @return [Symbol]
    def self.queue
      :skills
    end

    # Adds skills to the SkillRegistry
    # @param condition [Condition,Regexp] The condition that determines if this route applies
    # @param action [Symbol,String] The method on the Skill subclass to call
    # @param allowed_groups [Symbol,Array<Symbol>] The group or list of groups allowed to use this
    # @param help [String,Hash] A description of how to use the skill
    def self.route(condition, action, allowed_groups: :everyone, help: nil, name: nil, mention_only: true)
      name ||= "#{to_s.split("::").last.downcase}##{action}"
      real_cond = case condition
                  when Condition
                    condition
                  when Regexp
                    Conditions::Regex.new(condition, action, allowed_groups, help, mention_only)
                  else
                    log("Unknown condition for route for #{name}##{action}", :warn)
                    nil
                  end
      SkillRegistry.instance.register(name, self, real_cond) if real_cond
    end

    # @param sense [Class,String] Class (or Class name) of the source Sense
    # @param request [String,Integer] Reference to the request from the Sense provider (usually ID or message itself)
    # @param meta [Hash] Optional meta data that can be passed along from a Sense for use in Skills
    def initialize(sense, route, request, meta)
      @sense   = sense.is_a?(Class) ? sense : Module.const_get(sense)
      @route   = SkillRegistry.find_by_name(route)
      @request = request
      @tokens  = @route.tokens(message.body) || []
      @meta    = meta
    end

    # Provides a random entry from a list of canned acknowledgements
    # @return [String]
    def acknowledgement
      responses = [
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
        "Gladly!",
        "All right.",
        "I'm all over it.",
        "I'm on it!",
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
        meta: @meta,
        route: route.name
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
      sense.message_from_request(request)
    end

    def named_tokens
      @named_tokens ||= @route.named_tokens(message.body) || {}
    end

    # Defers to the Sense to react to a message
    # @param [String] type The type of reaction to send
    # @return [Boolean,String]
    def react(type)
      return false unless sense.supports?(:reactions)

      sense.react(request, type)
    end

    # Defers to the Sense to determine how to reply to a message
    # @param text [String] The reply text
    def reply(text, private: false)
      if private && sense.supports?(:private_messages)
        sense.private_reply(request, text)
      else
        log("Unable to send private message for Sense #{sense.name}, replying instead", :debug) if private
        sense.reply(request, text)
      end
    end

    # Defers to the Sense to determine how to reply to a message with rich content
    # @param blocks [String] The reply blocks
    def reply_with_blocks(blocks, private: false)
      unless sense.supports?(:blocks)
        log("Unable to use blocks with Sense #{sense.name}")
        return false
      end
      if private
        sense.private_reply_with_blocks(request, blocks)
      else
        log("Unable to send private message for Sense #{sense.name}, replying instead", :debug) if private
        sense.reply_with_blocks(request, blocks)
      end
    end

    # Defers to the Sense to do threaded replies if it can, otherwise it falls back to normal replies
    # @param text [String] The reply text
    def threaded_reply(text)
      if sense.supports?(:threads)
        sense.threaded_reply(request, text)
      else
        log("Unable to reply in theads for Sense #{sense.name}, replying instead", :debug)
        sense.reply(request, text)
      end
    end
  end
end
