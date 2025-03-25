require 'rails_helper'

RSpec.describe Instance, type: :model do
  describe "#secondary_reference?" do
    let(:instance) { FactoryBot.create(:instance, instance_type: instance_type) }

    context "when instance type is not a secondary instance" do
      let(:instance_type) { FactoryBot.create(:instance_type, secondary_instance: false)}
      it "returns false" do
        expect(instance.secondary_reference?).to eq false
      end
    end

    context "when instance type is a secondary instance" do
      let(:instance_type) { FactoryBot.create(:instance_type, secondary_instance: true)}
      it "returns true" do
        expect(instance.secondary_reference?).to eq true
      end
    end
  end

  describe "#copy_with_product_reference_allowed?" do
    let(:instance) { FactoryBot.create(:instance) }

    context "when the instance is standalone and not a draft" do
      before do
        allow(instance).to receive(:standalone?).and_return(true)
        allow(instance).to receive(:draft?).and_return(false)
      end

      it "returns true" do
        expect(instance.copy_with_product_reference_allowed?).to be true
      end
    end

    context "when the instance is not standalone" do
      before do
        allow(instance).to receive(:standalone?).and_return(false)
        allow(instance).to receive(:draft?).and_return(false)
      end

      it "returns false" do
        expect(instance.copy_with_product_reference_allowed?).to be false
      end
    end

    context "when the instance is a draft" do
      before do
        allow(instance).to receive(:standalone?).and_return(true)
        allow(instance).to receive(:draft?).and_return(true)
      end

      it "returns false" do
        expect(instance.copy_with_product_reference_allowed?).to be false
      end
    end

    context "when the instance is neither standalone nor a draft" do
      before do
        allow(instance).to receive(:standalone?).and_return(false)
        allow(instance).to receive(:draft?).and_return(true)
      end

      it "returns false" do
        expect(instance.copy_with_product_reference_allowed?).to be false
      end
    end
  end
end
