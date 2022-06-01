# frozen_string_literal: true

module Waylon
  module Skills
    # Built-in info routes
    class Diagnostics < Skill
      # Say hello to Waylon
      route(
        /^diagnostics|status$/i,
        :status,
        help: {
          usage: "diagnostics|status",
          description: "Retrieve this bot's current status"
        }
      )

      # Provides info about Waylon's status
      def status # rubocop:disable Metrics/AbcSize
        response = []
        response << "*Framework Version:* Waylon v#{Waylon::Core::VERSION}"
        response << "*Sense plugins:*"
        loaded_senses.each { |c| response << "  - #{c}" }
        response << "*Skill plugins:*"
        loaded_routes.each { |d| response << "  - #{d}" }
        response << "*Redis:*"
        state, read_time, write_time = test_redis
        response << "  - *Test Result:* #{state ? "Success" : "Error"}"
        response << "  - *Read time:* #{read_time}s"
        response << "  - *Write time:* #{write_time}s"
        if Resque.redis.connected?
          response << "*Queue Monitoring:*"
          response << "  - Failed jobs: #{Resque::Failure.count}"
        end

        reply response.join("\n")
      end

      def loaded_routes
        SkillRegistry.instance.routes.map { |r| r.destination.name }.sort.uniq
      end

      def loaded_senses
        SenseRegistry.instance.senses.map { |_s, c| c.name }.sort.uniq
      end

      def test_redis
        test_key = ("a".."z").to_a.sample(10).join
        test_value = (0..1000).to_a.sample(20).map(&:to_s).join
        test_result = nil

        write_time = Benchmark.realtime { db.store(test_key, test_value) }
        read_time = Benchmark.realtime { test_result = db.load(test_key) }

        db.delete(test_key)

        [(test_value == test_result), read_time.round(6), write_time.round(6)]
      end
    end
  end
end
