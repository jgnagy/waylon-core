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
      expect(subject).not_to be_configured

      ENV["CONF_TESTS_BASECOMPONENTTESTCLASS_OTHER"] = "this"
      Waylon::Config.instance.load_env
      expect(subject).to be_configured
      expect(Waylon::Config.instance).to be_value("tests.basecomponenttestclass.other")
      ENV.delete("CONF_TESTS_BASECOMPONENTTESTCLASS_OTHER")
      Waylon::Config.instance.delete("tests.basecomponenttestclass.other")
    end

    it "complains about then ignores invalid configurations" do
      expect(subject).not_to be_configured

      Waylon::Config.instance["tests.basecomponenttestclass.other"] = 0.1
      expect(subject).not_to be_configured
    end
  end

  context "with extended classes instances" do
    it "allows retrieving config values" do
      expect(subject_instance.config(:importance)).to eq "low"
    end

    it "provides a usable cache" do
      expect(Waylon::Cache.key?("tests.basecomponenttestclass.test")).not_to be true
      expect(subject_instance.cache(:test)).to be_nil
      expect(subject_instance.cache(:test) { "cachable output" }).to eq "cachable output"
      expect(Waylon::Cache.key?("tests.basecomponenttestclass.test")).to be true
      expect(subject_instance.cache(:test)).to be_truthy
      expect(subject_instance.cache(:test) { "cachable output" }).to eq "cachable output"
    end

    it "provides a usable, encrypted key/value store" do
      value_to_store = [1, 2, 3, 4]
      expect(subject_instance.db.load(:some_value)).to be_nil
      subject_instance.db.store(:some_value, value_to_store)
      expect(subject_instance.db.load(:some_value)).to eq(value_to_store)
      expect(subject_instance.db.storage.load(:some_value)).not_to eq(value_to_store)
      expect(subject_instance.db.storage.load(:some_value)).to be_a(String)
    end
  end
end
