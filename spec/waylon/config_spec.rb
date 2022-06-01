# frozen_string_literal: true

RSpec.describe Waylon::Config do
  subject do
    Waylon::Config.instance
  end

  it "stores things" do
    key = "global.testtest"
    expect(subject.value?(key)).not_to be
    subject[key] = "a test value"
    expect(subject.value?(key)).to be
    expect(subject[key]).to eq "a test value"
    expect(subject.delete(key))
  end

  it "provides defaults for required Redis values" do
    expect(subject.redis_host).to eq "redis"
    expect(subject.redis_port).to eq "6379"
  end

  it "provides defaults for required log levels" do
    expect(subject["global.log.level"]).to eq "INFO"
  end

  it "ignores attempts to set undefined non-global keys" do
    key = "other.testtest"
    expect(subject.value?(key)).not_to be
    subject[key] = "a test value"
    expect(subject.value?(key)).not_to be
  end

  it "is resettable" do
    key = "global.testtest"

    expect(subject.value?(key)).not_to be
    subject[key] = "a test value"
    expect(subject.value?(key)).to be
    subject.reset
    expect(subject.value?(key)).not_to be
  end
end
