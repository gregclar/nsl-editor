# frozen_string_literal: true

require "rails_helper"

describe Instances::ChangeNameService do
  let(:name_rank) { create(:name_rank) }
  let(:name_type) { create(:name_type) }
  let(:current_name) { create(:name, name_type:, name_rank:) }
  let(:draft_instance) { create(:instance, name: current_name, draft: true) }
  let(:username) { "test_editor" }

  subject(:service) do
    described_class.new(
      instance: draft_instance,
      new_name_id: new_name.id,
      username: username
    )
  end

  describe "#execute" do
    context "when the new name matches the current type and rank" do
      let(:new_name) { create(:name, name_type:, name_rank:) }

      it "changes the instance name in the database" do
        service.execute
        expect(draft_instance.reload.name_id).to eq(new_name.id)
      end

      it "records the user who made the change" do
        service.execute
        expect(draft_instance.reload.updated_by).to eq(username)
      end

      it "succeeds without errors" do
        service.execute
        expect(service.errors).to be_empty
      end
    end

    context "when the new name is already listed as a synonym" do
      let(:new_name) { create(:name, name_type:, name_rank:) }

      before do
        cites = build(:instance, name: new_name, reference: draft_instance.reference)
        cites.save(validate: false)
        syn = build(:instance, cited_by_id: draft_instance.id, cites_id: cites.id,
                               name: new_name, reference: draft_instance.reference)
        syn.save(validate: false)
      end

      it "does not change the instance name" do
        expect { service.execute }.not_to change { draft_instance.reload.name_id }
      end

      it "reports an error" do
        service.execute
        expect(service.errors).not_to be_empty
      end
    end

    context "when the new name has a different type" do
      let(:new_name) { create(:name, name_type: create(:name_type), name_rank:) }

      it "does not change the instance name" do
        expect { service.execute }.not_to change { draft_instance.reload.name_id }
      end

      it "reports an error" do
        service.execute
        expect(service.errors).not_to be_empty
      end
    end

    context "when the new name has a different rank" do
      let(:new_name) { create(:name, name_type:, name_rank: create(:name_rank)) }

      it "does not change the instance name" do
        expect { service.execute }.not_to change { draft_instance.reload.name_id }
      end

      it "reports an error" do
        service.execute
        expect(service.errors).not_to be_empty
      end
    end
  end
end
