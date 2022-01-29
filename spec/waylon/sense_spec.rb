# frozen_string_literal: true

RSpec.describe Waylon::Sense do
  let(:resque_details) do
    {
      "sense" => Waylon::Sense,
      "request" => 123,
      "route" => fake_route.name
    }
  end

  let(:fake_route) do
    route = instance_double("Route", name: "fake_name", destination: Waylon::Skills::Default, action: :unknown)
    allow(route).to receive(:tokens).with("some foo") { ["foo"] }
    route
  end

  it "provides a default way to present text as code" do
    expect(subject.codify("test")).to eq "```\ntest```"
  end

  it "generates a reasonable config namespace" do
    expect(subject.config_namespace).to eq "senses.sense"
  end

  it "enqueues work for processing by Skills" do
    expect(Resque).to receive(:enqueue).with(Waylon::Skills::Default, resque_details)
    subject.enqueue(fake_route, 123)
  end

  it "provides a queue name for use by Resque" do
    expect(subject.queue).to eq :senses
  end
end
