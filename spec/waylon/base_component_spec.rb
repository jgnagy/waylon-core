# frozen_string_literal: true

class BaseComponentTestClass
  include Waylon::BaseComponent

  # In extended classes, this is defined already
  def self.config_namespace
    "tests.#{component_namespace}"
  end

  config :importance, default: "low"
  config :other, required: true
end

RSpec.describe Waylon::BaseComponent do
  subject do
    BaseComponentTestClass
  end

  let(:subject_instance) do
    BaseComponentTestClass.new
  end

  context "when extending classes" do
    it "provides a reasonable component namespace" do
      expect(subject.component_namespace).to eq "basecomponenttestclass"
    end

    it "generates expected config keys" do
      expect(subject.config_key_for("foobar")).to eq "tests.basecomponenttestclass.foobar"
    end

    it "is configurable" do
      expect(subject.configured?).to be_falsey

      ENV["CONF_TESTS_BASECOMPONENTTESTCLASS_OTHER"] = "this"
      Waylon::Config.instance.load_env
      expect(subject.configured?).to be_truthy
      expect(Waylon::Config.instance.value?("tests.basecomponenttestclass.other")).to be_truthy
      ENV.delete("CONF_TESTS_BASECOMPONENTTESTCLASS_OTHER")
      Waylon::Config.instance.delete("tests.basecomponenttestclass.other")
    end

    it "complains about then ignores invalid configurations" do
      expect(subject.configured?).to be_falsey

      Waylon::Config.instance["tests.basecomponenttestclass.other"] = 0.1
      expect(subject.configured?).to be_falsey
    end
  end

  context "for instances of extended classes" do
    it "allows retrieving config values" do
      expect(subject_instance.config(:importance)).to eq "low"
    end

    it "provides a usable cache" do
      expect(Waylon::Cache.key?("tests.basecomponenttestclass.test")).not_to be true
      expect(subject_instance.cache(:test)).not_to be
      expect(subject_instance.cache(:test) { "cachable output" }).to eq "cachable output"
      expect(Waylon::Cache.key?("tests.basecomponenttestclass.test")).to be true
      expect(subject_instance.cache(:test)).to be
      expect(subject_instance.cache(:test) { "cachable output" }).to eq "cachable output"
    end
  end
end
