require "rails_helper"

RSpec.describe Users::ProfileContexts::Base, type: :service do
  let(:groups) { ["non-profile-product"] }
  let(:user) { FactoryBot.create(:user, groups: groups)}

  subject { described_class.new(user) }

  describe ".initialize" do
    it "has a logger instance variable" do
      expect(subject.instance_variable_get(:@logger)).to eq Rails.logger
    end

    it "has a product" do
      expect(subject.product).to eq "unknown"
    end

    it "has a user" do
      expect(subject.user).to eq user
    end
  end

  describe "#profile_view_allowed?" do
    it "returns true" do
      expect(subject.profile_view_allowed?).to eq false
    end
  end

  describe "#profile_edit_allowed?" do
    it "returns false" do
      expect(subject.profile_edit_allowed?).to eq false
    end
  end

  describe "#instance_edit_allowed?" do
    it "returns false" do
      expect(subject.instance_edit_allowed?).to eq false
    end
  end

  context "for undefined method" do
    it "return nil" do
      expect(subject.unknown_method).to eq nil
    end
  end
end