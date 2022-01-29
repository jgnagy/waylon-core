# frozen_string_literal: true

module Waylon
  module Skills
    # A Skill for providing help
    class Help < Skill
      # Ask for some help.
      # Defaults to all things a user has access to, but allows specifying either a Skill name or a Skill and Route
      route(
        /^help(?<skill_clause>\s+(?<skill>\w+)(?<action_clause>#(?<action>\w+)|\s+(?<action>\w+))?)?$/i,
        :help,
        help: {
          usage: "help [skill [action]]",
          description: "Allows asking for help, either for all skills or for a particular skill or action"
        }
      )

      # Responds to "help" requests
      def help
        skill = named_tokens[:skill]
        action = named_tokens[:action]

        react :book

        immediate_responses = [
          "I'll send you a DM to go over that with you.",
          "I'll DM you the details.",
          "Look for a private message with those details.",
          "You should have a private message with that information shortly."
        ]

        # Only send this if you aren't already in a DM
        threaded_reply "#{acknowledgement} #{immediate_responses.sample}" unless message.private?

        if sense.supports?(:blocks)
          reply_with_blocks(help_blocks(skill, action), private: true)
        else
          reply(help_text(skill, action), private: true)
        end
      end

      def help_text(skill = nil, action = nil) # rubocop:disable Metrics/AbcSize
        allowed_routes = SkillRegistry.instance.help(message.author)
        resp = []
        if skill
          if action
            resp << "## Help for #{skill}##{action}:"
            this_route = allowed_routes[skill].find do |r|
              r[:name].to_s == "#{skill}##{action}"
            end
            return "I couldn't find #{action} on #{skill}..." unless this_route

            resp << build_help_text(this_route)
          else
            resp << "## Help for #{skill}:\n"
            routes = allowed_routes[skill]
            (routes || []).each { |r| resp << build_help_text(r) }
          end
        else
          help_text_for_all(allowed_routes)
        end
      end

      def help_blocks(skill = nil, action = nil) # rubocop:disable Metrics/AbcSize
        allowed_routes = SkillRegistry.instance.help(message.author)
        if skill
          if action
            this_route = allowed_routes[skill].find do |r|
              r[:name].to_s == "#{skill}##{action}"
            end

            return not_found_block(skill, action) unless this_route

            [build_header_block(skill, action), build_help_block(this_route)]
          else
            routes = allowed_routes[skill]
            return not_found_block(skill, nil) unless routes

            resp = [build_header_block(skill, nil)]
            routes.each { |r| resp << build_help_block(r) }
            resp
          end
        else
          allowed_routes = SkillRegistry.instance.help(message.author)
          help_blocks_for_all(allowed_routes)
        end
      end

      def help_blocks_for_all(routes)
        resp = [
          { type: "header", text: { type: "plain_text", text: "All known actions:", emoji: true } }
        ]

        routes.each do |k, v|
          resp += [
            { type: "divider" },
            {
              type: "section",
              text: {
                type: "mrkdwn",
                text: "*Actions for '#{k}':*"
              }
            }
          ]
          v.each { |r| resp << build_help_block(r) }
        end
        resp
      end

      def help_text_for_all(routes)
        resp = []
        resp << "*All known actions:*\n"
        routes.each do |k, v|
          resp << "* *#{k}*:"
          v.each do |r|
            resp << build_help_text(r)
          end
          resp << " --- "
        end
        resp.join("\n")
      end

      def build_header_block(skill, action)
        text = if action
                 "Help for #{skill}##{action}:"
               else
                 "Help for #{skill}:"
               end
        { type: "header", text: { type: "plain_text", text: text, emoji: true } }
      end

      def build_help_block(this_route)
        {
          type: "section",
          text: {
            type: "mrkdwn",
            text: "  *#{this_route[:name]}*\n#{build_help_text(this_route)}"
          }
        }
      end

      def build_help_text(this_route)
        route_help_text = []
        case this_route[:help]
        when String
          route_help_text << "    *Usage:* #{this_route[:help]}"
        when Hash
          route_help_text << "    *Usage:* #{this_route.dig(:help, :usage)}"
          if this_route.dig(:help, :description)
            route_help_text << "\n    *Description:* #{this_route.dig(:help, :description)}"
          end
        end
        route_help_text.join
      end

      def not_found_block(skill, action)
        sentence = if action
                     "I couldn't find any '#{action}' action on the '#{skill}' skill..."
                   else
                     "I couldn't find any routes related to a '#{skill}' skill..."
                   end
        [
          {
            type: "section",
            text: {
              type: "mrkdwn",
              text: sentence
            }
          }
        ]
      end
    end
  end
end
