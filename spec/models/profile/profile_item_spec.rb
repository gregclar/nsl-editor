require 'rails_helper'

RSpec.describe Profile::ProfileItem, type: :model do

  describe "associations" do
    it { is_expected.to belong_to(:instance) }
    it { is_expected.to belong_to(:product_item_config).class_name('Profile::ProductItemConfig').with_foreign_key('product_item_config_id') }
    it { is_expected.to belong_to(:profile_text).class_name('Profile::ProfileText').with_foreign_key('profile_text_id').dependent(:destroy) }
    it { is_expected.to belong_to(:profile_object_type).class_name('Profile::ProfileObjectType').with_primary_key('rdf_id').with_foreign_key('profile_object_rdf_id').optional }
    it { is_expected.to have_many(:profile_item_references).class_name('Profile::ProfileItemReference').with_foreign_key('profile_item_id').dependent(:destroy) }
    it { is_expected.to have_one(:product).through(:product_item_config) }
    it { is_expected.to have_one(:profile_item_annotation).class_name('Profile::ProfileItemAnnotation').with_foreign_key('profile_item_id').dependent(:destroy) }
    it { is_expected.to have_many(:sourced_in_profile_items).class_name('Profile::ProfileItem').with_foreign_key('source_profile_item_id') }
  end

  describe "#allow_delete?" do
    let(:profile_item) { FactoryBot.create(:profile_item) }

    context "when there are no sourced_in_profile_items" do
      it "returns true" do
        expect(profile_item.allow_delete?).to be true
      end
    end

    context "when there are sourced_in_profile_items" do
      before do
        allow_any_instance_of(Name).to receive(:name_type_must_match_category).and_return(true)
        FactoryBot.create(:profile_item, source_profile_item_id: profile_item.id, profile_object_rdf_id: profile_item.profile_object_rdf_id, product_item_config: profile_item.product_item_config)
      end

      it "returns false" do
        expect(profile_item.allow_delete?).to be false
      end
    end
  end

end
