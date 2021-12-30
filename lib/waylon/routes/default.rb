# frozen_string_literal: true

module Waylon
  module Routes
    # The default route for unrouted messages
    class Default < Route
      def initialize(
        name: "default_route",
        destination: Skills::Default,
        condition: Conditions::Default.new,
        priority: 0
      )
        super
      end
    end
  end
end
