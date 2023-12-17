# frozen_string_literal: true

RSpec.describe Waylon::Config do
  subject do
    described_class.instance
  end

  it "stores things" do
    key = "global.testtest"
    expect(subject.value?(key)).to be false
    subject[key] = "a test value"
    expect(subject).to be_value(key)
    expect(subject[key]).to eq "a test value"
    expect(subject.delete(key)).to be_truthy
  end

  it "provides defaults for required Redis values" do
    expect(subject.redis_host).to eq "localhost"
    expect(subject.redis_port).to eq "6379"
  end

  it "provides defaults for required log levels" do
    expect(subject["global.log.level"].downcase).to eq "info"
  end

  it "ignores attempts to set undefined non-global keys" do
    key = "other.testtest"
    expect(subject).not_to be_value(key)
    subject[key] = "a test value"
    expect(subject).not_to be_value(key)
  end

  it "is resettable" do
    key = "global.testtest"

    expect(subject).not_to be_value(key)
    subject[key] = "a test value"
    expect(subject).to be_value(key)
    subject.reset
    expect(subject).not_to be_value(key)
  end
end
