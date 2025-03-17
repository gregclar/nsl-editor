require 'rails_helper'

RSpec.describe Profile::ProfileItem, type: :model do
  describe 'before_destroy callback: validate_source_profile_item_id' do
    let!(:profile_item) { FactoryBot.create(:profile_item) }

    context 'when the profile item is not cited by other items' do
      it 'allows the profile item to be destroyed' do
        expect { profile_item.destroy }.to change(Profile::ProfileItem, :count).by(-1)
      end
    end

    context 'when the profile item is cited by other items' do
      before do
        allow_any_instance_of(Name).to receive(:name_type_must_match_category).and_return(true)
        FactoryBot.create(:profile_item, source_profile_item_id: profile_item.id, profile_object_rdf_id: profile_item.profile_object_rdf_id, product_item_config: profile_item.product_item_config)
      end

      it 'does not allow the profile item to be destroyed' do
        expect { profile_item.destroy }.not_to change(Profile::ProfileItem, :count)
        expect(profile_item.errors[:base]).to include("Cannot delete profile item as it has been cited by 1 other items")
      end
    end

    context 'when the profile item is cited by multiple items' do
      before do
        allow_any_instance_of(Name).to receive(:name_type_must_match_category).and_return(true)
      end

      it 'does not allow the profile item to be destroyed and shows the correct error message' do
        other_profile_item_1 = FactoryBot.create(:profile_item, source_profile_item_id: profile_item.id, profile_object_rdf_id: profile_item.profile_object_rdf_id, product_item_config: profile_item.product_item_config)
        other_profile_item_2 = FactoryBot.create(:profile_item, source_profile_item_id: profile_item.id, profile_object_rdf_id: profile_item.profile_object_rdf_id, product_item_config: profile_item.product_item_config)

        expect { profile_item.destroy }.not_to change(Profile::ProfileItem, :count)
        expect(profile_item.errors[:base]).to include("Cannot delete profile item as it has been cited by 2 other items")
      end
    end
  end
end
