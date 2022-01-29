# frozen_string_literal: true

require "waylon/skills/diagnostics"

RSpec.describe Waylon::Skills::Diagnostics do
  %w[status diagnostics].each do |phrase|
    it { is_expected.to route(phrase).to(:status) }
  end
end
