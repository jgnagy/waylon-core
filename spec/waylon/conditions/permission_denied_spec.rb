# frozen_string_literal: true

RSpec.describe Waylon::Conditions::PermissionDenied do
  subject do
    described_class.new
  end

  it "matches any text input" do
    ["this", "", nil, "some other test"].each do |input|
      expect(subject.matches?(input)).to be true
    end
  end

  it "permits any user" do
    Waylon::RSpec::TestSense.user_list.each do |user|
      expect(subject.permits?(user)).to be true
    end
  end

  it "returns text input as a tokens array" do
    ["this", "", "baño", "some other test"].each do |input|
      expect(subject.tokens(input)).to eq([input])
    end
  end

  it "points to the appropriate action" do
    expect(subject.action).to eq(:denied)
  end

  it "provides the appropriate help text" do
    expect(subject.help).to include("action is not allowed")
  end
end
