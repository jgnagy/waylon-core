# frozen_string_literal: true

require "waylon/skills/groups"

RSpec.describe Waylon::Skills::Groups do
  it { is_expected.to route("groups").to(:list_my_groups) }

  ["list all groups", "cleanup groups"].each do |phrase|
    it { is_expected.not_to route(phrase).to(phrase.gsub(" ", "_").to_sym) }
    it { is_expected.to route(phrase).as_member_of(:admins).to(phrase.gsub(" ", "_").to_sym) }
    it { is_expected.to route(phrase).as_member_of(:group_admins).to(phrase.gsub(" ", "_").to_sym) }
  end
end
