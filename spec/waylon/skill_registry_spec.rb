# frozen_string_literal: true

module Waylon
  module Skills
    # A test skill
    class TestSkillWithPermissions < Skill
      route(
        /^a test$/i,
        :run_test,
        allowed_groups: :admins,
        help: "a test"
      )

      # Runs a test
      def run_test
        reply "On it!"
      end
    end
  end
end

RSpec.describe Waylon::SkillRegistry do
  subject do
    described_class.instance
  end

  it "provides help based on user permissions" do
    expect(subject.help(testuser)).to be_a Hash
    expect(subject.help(testuser).keys).not_to include("skills.testskillwithpermissions")
    expect(subject.help(adminuser)).to be_a Hash
    expect(subject.help(adminuser)).to include(
      { "testskillwithpermissions" => [{ help: "a test", name: "testskillwithpermissions#run_test" }] }
    )
  end
end
