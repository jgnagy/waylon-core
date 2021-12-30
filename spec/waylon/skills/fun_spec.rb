# frozen_string_literal: true

require "waylon/skills/fun"

RSpec.describe Waylon::Skills::Fun do
  %w[hi hello].each do |phrase|
    it { is_expected.to route(phrase).to(:hello) }
  end

  it "routes messages as expected" do
    send_message("hello")
    expect(replies.last).to start_with("H")
  end
end
