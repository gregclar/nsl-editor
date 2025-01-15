require 'rails_helper'

RSpec.describe InstanceType, type: :model do
  describe "#secondary_instance?" do
    context "when instance type is not a secondary instance" do
      let(:instance_type) { FactoryBot.create(:instance_type, secondary_instance: false) }
      it "returns false" do
        expect(instance_type.secondary_instance?).to eq false
      end
    end

    context "when instance type is a secondary instance" do
      let(:instance_type) { FactoryBot.create(:instance_type, secondary_instance: true) }
      it "returns true" do
        expect(instance_type.secondary_instance?).to eq true
      end
    end
  end
end
