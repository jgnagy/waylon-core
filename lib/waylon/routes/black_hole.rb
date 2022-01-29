# frozen_string_literal: true

module Waylon
  module Routes
    # The route for unroutable events
    class BlackHole < Route
      def initialize(
        name: "black_hole",
        destination: Skills::Default,
        condition: Conditions::BlackHole.new,
        priority: 0
      )
        super
      end
    end
  end
end
