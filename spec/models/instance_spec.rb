require 'rails_helper'

RSpec.describe Instance, type: :model do
  let(:instance) { FactoryBot.create(:instance) }

  describe "#delete_as_user" do
    let(:instance_type) { FactoryBot.create(:instance_type, secondary_instance: false)}
    let(:instance) { FactoryBot.create(:instance, instance_type: instance_type) }
    let(:username) { "test_user" }

    context "when deletion is successful" do
      before do
        allow(Instance::AsServices).to receive(:delete).with(instance.id).and_return(true)
      end

      it "updates the updated_by field with the username" do
        expect(instance).to receive(:update_attribute).with(:updated_by, username)
        instance.delete_as_user(username)
      end
    end

    context "when an exception occurs" do
      before do
        allow(Instance::AsServices).to receive(:delete).with(instance.id).and_raise(StandardError, "Deletion failed")
        allow(Rails.logger).to receive(:error)
      end

      it "logs the exception" do
        expect(Rails.logger).to receive(:error).with(/delete_as_user exception: Deletion failed/)
        expect { instance.delete_as_user(username) }.to raise_error(StandardError, "Deletion failed")
      end

      it "raises the exception" do
        expect { instance.delete_as_user(username) }.to raise_error(StandardError, "Deletion failed")
      end
    end
  end

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

  describe "#allow_delete?" do
    context "when all conditions are met for deletion" do
      before do
        allow(instance).to receive(:instance_notes).and_return([])
        allow(instance).to receive(:reverse_of_this_cites).and_return([])
        allow(instance).to receive(:reverse_of_this_is_cited_by).and_return([])
        allow(instance).to receive(:comments).and_return([])
        allow(instance).to receive(:in_any_tree?).and_return(false)
        allow(instance).to receive(:children).and_return([])
        allow(instance).to receive(:not_linked_to_loader_name_matches?).and_return(true)
        allow(instance).to receive(:profile_items).and_return([])
      end

      it "returns true" do
        expect(instance.allow_delete?).to be true
      end
    end

    context "when instance_notes are present" do
      before do
        allow(instance).to receive(:instance_notes).and_return([double])
        allow(instance).to receive(:reverse_of_this_cites).and_return([])
        allow(instance).to receive(:reverse_of_this_is_cited_by).and_return([])
        allow(instance).to receive(:comments).and_return([])
        allow(instance).to receive(:in_any_tree?).and_return(false)
        allow(instance).to receive(:children).and_return([])
        allow(instance).to receive(:not_linked_to_loader_name_matches?).and_return(true)
        allow(instance).to receive(:profile_items).and_return([])
      end

      it "returns false" do
        expect(instance.allow_delete?).to be false
      end
    end

    context "when reverse_of_this_cites are present" do
      before do
        allow(instance).to receive(:instance_notes).and_return([])
        allow(instance).to receive(:reverse_of_this_cites).and_return([double])
        allow(instance).to receive(:reverse_of_this_is_cited_by).and_return([])
        allow(instance).to receive(:comments).and_return([])
        allow(instance).to receive(:in_any_tree?).and_return(false)
        allow(instance).to receive(:children).and_return([])
        allow(instance).to receive(:not_linked_to_loader_name_matches?).and_return(true)
        allow(instance).to receive(:profile_items).and_return([])
      end

      it "returns false" do
        expect(instance.allow_delete?).to be false
      end
    end

    context "when reverse_of_this_is_cited_by are present" do
      before do
        allow(instance).to receive(:instance_notes).and_return([])
        allow(instance).to receive(:reverse_of_this_cites).and_return([])
        allow(instance).to receive(:reverse_of_this_is_cited_by).and_return([double])
        allow(instance).to receive(:comments).and_return([])
        allow(instance).to receive(:in_any_tree?).and_return(false)
        allow(instance).to receive(:children).and_return([])
        allow(instance).to receive(:not_linked_to_loader_name_matches?).and_return(true)
        allow(instance).to receive(:profile_items).and_return([])
      end

      it "returns false" do
        expect(instance.allow_delete?).to be false
      end
    end

    context "when comments are present" do
      before do
        allow(instance).to receive(:instance_notes).and_return([])
        allow(instance).to receive(:reverse_of_this_cites).and_return([])
        allow(instance).to receive(:reverse_of_this_is_cited_by).and_return([])
        allow(instance).to receive(:comments).and_return([double])
        allow(instance).to receive(:in_any_tree?).and_return(false)
        allow(instance).to receive(:children).and_return([])
        allow(instance).to receive(:not_linked_to_loader_name_matches?).and_return(true)
        allow(instance).to receive(:profile_items).and_return([])
      end

      it "returns false" do
        expect(instance.allow_delete?).to be false
      end
    end

    context "when the instance is in a tree" do
      before do
        allow(instance).to receive(:instance_notes).and_return([])
        allow(instance).to receive(:reverse_of_this_cites).and_return([])
        allow(instance).to receive(:reverse_of_this_is_cited_by).and_return([])
        allow(instance).to receive(:comments).and_return([])
        allow(instance).to receive(:in_any_tree?).and_return(true)
        allow(instance).to receive(:children).and_return([])
        allow(instance).to receive(:not_linked_to_loader_name_matches?).and_return(true)
        allow(instance).to receive(:profile_items).and_return([])
      end

      it "returns false" do
        expect(instance.allow_delete?).to be false
      end
    end

    context "when children are present" do
      before do
        allow(instance).to receive(:instance_notes).and_return([])
        allow(instance).to receive(:reverse_of_this_cites).and_return([])
        allow(instance).to receive(:reverse_of_this_is_cited_by).and_return([])
        allow(instance).to receive(:comments).and_return([])
        allow(instance).to receive(:in_any_tree?).and_return(false)
        allow(instance).to receive(:children).and_return([double])
        allow(instance).to receive(:not_linked_to_loader_name_matches?).and_return(true)
        allow(instance).to receive(:profile_items).and_return([])
      end

      it "returns false" do
        expect(instance.allow_delete?).to be false
      end
    end

    context "when linked to loader name matches" do
      before do
        allow(instance).to receive(:instance_notes).and_return([])
        allow(instance).to receive(:reverse_of_this_cites).and_return([])
        allow(instance).to receive(:reverse_of_this_is_cited_by).and_return([])
        allow(instance).to receive(:comments).and_return([])
        allow(instance).to receive(:in_any_tree?).and_return(false)
        allow(instance).to receive(:children).and_return([])
        allow(instance).to receive(:not_linked_to_loader_name_matches?).and_return(false)
        allow(instance).to receive(:profile_items).and_return([])
      end

      it "returns false" do
        expect(instance.allow_delete?).to be false
      end
    end

    context "when profile_items are present" do
      before do
        allow(instance).to receive(:instance_notes).and_return([])
        allow(instance).to receive(:reverse_of_this_cites).and_return([])
        allow(instance).to receive(:reverse_of_this_is_cited_by).and_return([])
        allow(instance).to receive(:comments).and_return([])
        allow(instance).to receive(:in_any_tree?).and_return(false)
        allow(instance).to receive(:children).and_return([])
        allow(instance).to receive(:not_linked_to_loader_name_matches?).and_return(true)
        allow(instance).to receive(:profile_items).and_return([double])
      end

      it "returns false" do
        expect(instance.allow_delete?).to be false
      end
    end
  end
end
