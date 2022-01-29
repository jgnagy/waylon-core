# frozen_string_literal: true

module Waylon
  module Skills
    # Built-in skills for managing groups
    class Groups < Skill
      route(
        /^add (.+) to (.+)$/,
        :add_to_group,
        help: {
          usage: "add USER[,USER] to GROUP",
          description: "Add USER(s) to a GROUP"
        },
        allowed_groups: %i[admins group_admins]
      )

      route(
        /^remove (.+) from (.+)$/,
        :remove_from_group,
        help: {
          usage: "remove USER[,USER] from GROUP",
          description: "Remove USER(s) from a GROUP"
        },
        allowed_groups: %i[admins group_admins]
      )

      route(
        /^(describe|list|print|show) (all )?(groups|group memberships)$/,
        :list_all_groups,
        help: {
          usage: "list all groups",
          description: "List all groups and their members"
        },
        allowed_groups: %i[admins group_admins]
      )

      route(
        /^cleanup groups$/,
        :cleanup_groups,
        help: {
          usage: "cleanup groups",
          description: "Remove empty groups"
        },
        allowed_groups: %i[admins group_admins]
      )

      route(
        /^((list )?my )?groups$/,
        :list_my_groups,
        help: {
          usage: "list my groups",
          description: "List my group memberships"
        }
      )

      def add_to_group # rubocop:disable Metrics/AbcSize
        user_list = tokens.first
        group_name = tokens.last

        if group_name == "global admins"
          reply "Sorry, I can't manipulate global admins this way..."
          return
        end

        group = Group.new(group_name)

        log "Adding #{user_list} to group #{group}"

        failures = []
        user_list.split(",").each do |this_user|
          found = found_user(this_user)
          failures << found unless group.add(found)
        end

        unless failures.empty?
          text = failures.size > 1 ? "were already members" : "was already a member"
          reply "Looks like [#{failures.map { |u| mention(u) }.join(", ")}] #{text} of #{group_name}"
        end

        reply("Done adding users to #{group_name}!")
      end

      def cleanup_groups
        # perform a key scan in Redis for all group keys and find empty groups
        group_keys = all_group_keys.select do |group|
          name = group.split(".").last
          Group.new(name).to_a.empty?
        end

        # delete the empty group keys
        group_keys.each { |g| db.delete(g) }

        group_names = group_keys.map { |g| g.split(".").last }

        reply "I removed these empty groups: #{group_names.join(", ")}"
      end

      def remove_from_group # rubocop:disable Metrics/AbcSize
        user_list = tokens.first
        group_name = tokens.last

        if group_name == "global admins"
          reply "Sorry, I can't manipulate global admins this way..."
          return
        end

        group = Group.new(group_name)

        log "Removing #{user_list} from group '#{group_name}'", :debug

        failures = []
        user_list.split(",").each do |this_user|
          found = found_user(this_user)
          failures << found unless group.remove(found)
        end

        unless failures.empty?
          text = failures.size > 1 ? "were members" : "was a member"
          reply("I don't think [#{failures.map { |u| mention(u) }.join(", ")}] #{text} of #{group_name}")
        end
        reply("Done removing users from groups!")
      end

      def list_all_groups
        groups = {}
        groups["global admins"] = global_admins unless global_admins.empty?
        all_group_keys.each do |group|
          name = group.split(".").last
          groups[name] = Group.new(name).members
        end

        reply(codify(groups.to_yaml))
      end

      def list_my_groups
        groups = []
        groups << "global admins" if global_admins.include?(message.author.email)
        all_group_keys.each do |group|
          name = group.split(".").last
          groups << name if Group.new(name).include?(message.author)
        end

        reply(codify(groups.to_yaml))
      end

      private

      def all_group_keys
        db.adapter.backend.keys("groups.*")
      end

      def found_user(user_string)
        if user_string =~ /^.+@.+/
          # If provided an email
          sense.user_class.find_by_email(user_string)
        else
          # Otherwise assume we're provided their user ID
          sense.user_class.from_mention(user_string)
        end
      end

      def global_admins
        Config.instance.admins
      end
    end
  end
end
