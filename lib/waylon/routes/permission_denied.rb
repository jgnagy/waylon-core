# frozen_string_literal: true

module Waylon
  module Routes
    # This route is used when a route exists but the current user doesn't have permission
    class PermissionDenied < Route
      def initialize(
        name: "permission_denied",
        destination: Skills::Default,
        condition: Conditions::PermissionDenied.new,
        priority: 99
      )
        super
      end
    end
  end
end
