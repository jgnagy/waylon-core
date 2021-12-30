# frozen_string_literal: true

module Waylon
  module Skills
    # A place for some builtin fun
    class Fun < Skill
      # Say hello to Waylon
      route(
        /^(hello|hi)$/i,
        :hello
      )

      # Responds to "hello" in less boring ways
      def hello
        responses = [
          "Hello there!",
          "Hi!",
          "Hi, how's it going?",
          "How can I be of service?"
        ]

        reply responses.sample
      end
    end
  end
end
