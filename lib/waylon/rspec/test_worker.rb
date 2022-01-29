# frozen_string_literal: true

module Waylon
  module RSpec
    # A TestWorker to run queued Skills
    class TestWorker
      # Instructs the worker to grab an item off the Queue and run it
      # @param queue [Queue] The queue that contains work to be done
      def self.handle(queue)
        skill, details = queue.pop
        skill.perform(details)
      end
    end
  end
end
