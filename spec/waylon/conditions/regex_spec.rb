# frozen_string_literal: true

RSpec.describe Waylon::Conditions::Regex do
  subject do
    described_class.new(
      /^say\s(.+)\sto\sme[.!]?$/,
      :foobar,
      :a_group,
      "Some help text"
    )
  end

  it "matches expected text input" do
    ["say this stuff to me", "say this other stuff to me!", "say foo to me."].each do |input|
      expect(subject).to be_matches(input)
    end
  end

  it "doesn't match other text input" do
    ["", "hi there", "Do it now!"].each do |input|
      expect(subject).not_to be_matches(input)
    end
  end

  it "denies users not a member of the right group(s)" do
    expect(subject.permits?(testuser)).to be false
  end

  it "allows admins users" do
    expect(subject.permits?(adminuser)).to be true
  end

  it "returns text input as a tokens array" do
    expect(subject.tokens("say this stuff to me")).to eq(["this stuff"])
    expect(subject.tokens("say this other stuff to me!")).to eq(["this other stuff"])
    expect(subject.tokens("say foo to me")).to eq(["foo"])
  end

  it "points to the appropriate action" do
    expect(subject.action).to eq(:foobar)
  end
end
