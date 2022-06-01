# frozen_string_literal: true

class TestCondition < Waylon::Condition
  def matches?(message)
    message.include?(@mechanism)
  end

  def tokens(input)
    input.split(/\s/)
  end
end

RSpec.describe Waylon::Condition do
  context "for simple conditions" do
    subject do
      TestCondition.new("success", :test, [:everyone])
    end

    let(:test_message) do
      Waylon::RSpec::TestMessage.new(99, { text: "some success" })
    end

    it "matches expected text input" do
      ["say success to me", "say this other stuff for success!", "success to me."].each do |input|
        expect(subject.matches?(input)).to be_truthy
      end
    end

    it "doesn't match other text input" do
      ["", "hi there", "Do it now!"].each do |input|
        expect(subject.matches?(input)).to be_falsey
      end
    end

    it "denies users not a member of the right group(s)" do
      expect(subject.permits?(testuser)).to be true
    end

    it "allows admins users" do
      expect(subject.permits?(adminuser)).to be true
    end

    it "returns text input as a tokens array" do
      expect(subject.tokens("say this stuff to me")).to eq(%w[say this stuff to me])
      expect(subject.tokens("say this other stuff to me!")).to eq(%w[say this other stuff to me!])
      expect(subject.tokens("say foo to me")).to eq(%w[say foo to me])
    end

    it "points to the appropriate action" do
      expect(subject.action).to eq(:test)
    end

    it "handles mention expectations" do
      expect(subject.properly_mentions?(test_message)).to be true
    end
  end

  context "for complex conditions" do
    let(:mention_only_condition) do
      TestCondition.new("other", :blah, [:admins])
    end

    let(:non_mention_only_condition) do
      TestCondition.new("other", :blah, [:admins], nil, false)
    end

    let(:test_message) do
      message = Waylon::RSpec::TestMessage.new(99, { text: "some other success" })
      message.define_singleton_method(:to_bot?) { false }
      message
    end

    let(:test_message_to_bot) do
      message = Waylon::RSpec::TestMessage.new(99, { text: "some other message" })
      message.define_singleton_method(:to_bot?) { true }
      message
    end

    describe "for mention only conditions" do
      it "matches expected text input" do
        ["say other to me", "say this other stuff!", "other to me."].each do |input|
          expect(mention_only_condition.matches?(input)).to be_truthy
        end
      end

      it "doesn't match other text input" do
        ["", "hi there", "Do it now!"].each do |input|
          expect(mention_only_condition.matches?(input)).to be_falsey
        end
      end

      it "denies users not a member of the right group(s)" do
        expect(mention_only_condition.permits?(testuser)).to be false
      end

      it "allows admins users" do
        expect(mention_only_condition.permits?(adminuser)).to be true
      end

      it "points to the appropriate action" do
        expect(mention_only_condition.action).to eq(:blah)
      end

      it "handles mention expectations" do
        expect(mention_only_condition.properly_mentions?(test_message)).to be false
        expect(mention_only_condition.properly_mentions?(test_message_to_bot)).to be true
      end
    end

    describe "for generic conditions" do
      it "matches expected text input" do
        ["say other to me", "say this other stuff!", "other to me."].each do |input|
          expect(non_mention_only_condition.matches?(input)).to be_truthy
        end
      end

      it "doesn't match other text input" do
        ["", "hi there", "Do it now!"].each do |input|
          expect(non_mention_only_condition.matches?(input)).to be_falsey
        end
      end

      it "denies users not a member of the right group(s)" do
        expect(non_mention_only_condition.permits?(testuser)).to be false
      end

      it "allows admins users" do
        expect(non_mention_only_condition.permits?(adminuser)).to be true
      end

      it "points to the appropriate action" do
        expect(non_mention_only_condition.action).to eq(:blah)
      end

      it "handles mention expectations" do
        expect(non_mention_only_condition.properly_mentions?(test_message)).to be true
        expect(non_mention_only_condition.properly_mentions?(test_message_to_bot)).to be true
      end
    end
  end
end
