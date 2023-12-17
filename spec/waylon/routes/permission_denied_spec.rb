# frozen_string_literal: true

RSpec.describe Waylon::Routes::PermissionDenied do
  subject do
    described_class.new
  end

  # Most route testing things are already covered by ../conditions/permission_denied_spec.rb

  it "uses the expected condition" do
    expect(subject.condition).to be_a(Waylon::Conditions::PermissionDenied)
  end

  it "routes to the expected destination" do
    expect(subject.destination).to be(Waylon::Skills::Default)
  end

  it "has the expected name" do
    expect(subject.name).to eq "permission_denied"
  end

  it "has the expected priority" do
    expect(subject.priority).to eq 99
  end
end
