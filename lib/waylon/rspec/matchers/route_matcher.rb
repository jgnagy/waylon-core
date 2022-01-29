# frozen_string_literal: true

module Waylon
  module RSpec
    module Matchers
      # RSpec matchers for Routes defined in Skills
      module RouteMatcher
        extend ::RSpec::Matchers::DSL

        # Validates that the provided message is routable
        matcher :route do |body|
          match do
            message = chatroom.post_message(body, from: testuser)

            if defined?(@group)
              # Add the test user to the group
              Group.new(@group.to_s).add(testuser)
            end

            found_route = SkillRegistry.instance.route(message)

            if defined?(@method_name)
              # Verify that the route sends to the appropriate place
              found_route &&
                found_route.destination == described_class &&
                found_route.action == @method_name.to_sym
            else
              found_route && found_route.destination == described_class
            end
          end

          chain :as_member_of do |group|
            @group = group
          end

          chain :to do |method_name|
            @method_name = method_name
          end

          description do
            result = "route \"#{expected}\""
            result += " to action \"#{@method_name}\"" if @method_name
            result += " while a member of \"#{@group}\"" if @group
            result
          end
        end
      end
    end
  end
end
