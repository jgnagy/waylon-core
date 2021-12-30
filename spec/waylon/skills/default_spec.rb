# frozen_string_literal: true

RSpec.describe Waylon::Conditions::Default do
  it "routes messages as expected" do
    send_message("foobar")
    expect(replies.last(2)).to include(":shrug:")
    expect(replies.last).to include("Use `help`")
  end
end
