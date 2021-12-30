# frozen_string_literal: true

module Waylon
  module Skills
    # The default skill for Waylon, mostly for fallback actions like permissions issues
    class Default < Skill
      # This action is performed when a User tries to run something they aren't allowed to
      def denied
        log("Denied '#{tokens.first}' from #{message.author.email}")
        prefix = message.private_message? ? "" : "#{mention(message.author)},"

        react :lock

        responses = [
          "I can't do that. You'll need an admin adjust your permissions.",
          "I know what you'd like to do, but you don't have permission for that.",
          "You don't have permission to do that."
        ]

        reply("#{prefix} #{responses.sample} #{help_postfix}")
      end

      # A useful addition to message to tell the User how to get help
      # @return [String]
      def help_postfix
        "Use `help` to see what you're allowed to do."
      end

      # This is run for unroutable messages (meaning no Skill has claimed them)
      def unknown
        log("Unroutable message '#{tokens.first}' from #{message.author.email}")

        prefix = message.private_message? ? "" : "#{mention(message.author)},"

        react :shrug

        responses = [
          "Sorry, I'm not sure what you mean by that.",
          "I don't have the ability to handle that request, but PRs are welcome!",
          "I don't know what that means.",
          "My AI and NLP is only so good... Maybe try rephrasing that request?"
        ]

        reply("#{prefix} #{responses.sample} #{help_postfix}")
      end
    end
  end
end
