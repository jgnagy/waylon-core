# frozen_string_literal: true

require "rspec"
require "rspec/expectations"
require "rspec/mocks"

major, *_unused = RSpec::Core::Version::STRING.split(/\./)
abort "RSpec 3 or greater required" if major.to_i < 3

require "moneta"
require "set"

require "waylon/core"
require "waylon/skills/default"
require "waylon/rspec/skill"
require "waylon/rspec/test_channel"
require "waylon/rspec/test_message"
require "waylon/rspec/test_sense"
require "waylon/rspec/test_user"
require "waylon/rspec/test_worker"

module Waylon
  # RSpec stuff that allows specialized Waylon testing
  module RSpec
    class << self
      # @param base [Object] The class including the module.
      # @return [void]
      def included(base)
        base.class_eval do
          before do
            config = Waylon::Config.instance
            config.load_env
            Waylon::Cache.clear
            Waylon::Storage.clear

            Waylon::RSpec::TestChannel.find_or_create("random")
            Waylon::RSpec::TestUser.find_or_create(
              name: "Waylon Smithers",
              email: "waylon.smithers@example.com"
            )
            Waylon::RSpec::TestUser.find_or_create(name: "Homer Simpson")
          end
        end
      end
    end
  end
end

Waylon::Cache = Moneta.new(:Cookie)
Waylon::Storage = Moneta.new(:Cookie)
