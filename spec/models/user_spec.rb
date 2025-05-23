require 'rails_helper'

RSpec.describe User, type: :model do

  describe "associations" do
    it { is_expected.to have_many(:batch_reviewers).class_name('Loader::Batch::Reviewer').with_foreign_key('user_id') }
    it { is_expected.to have_many(:user_product_roles).class_name('User::ProductRole').with_foreign_key('user_id') }
    it { is_expected.to have_many(:product_roles).through(:user_product_roles) }
    it { is_expected.to have_many(:products).through(:product_roles) }
    it { is_expected.to have_many(:roles).through(:product_roles) }
  end

  describe '#is?' do
    let(:user) { FactoryBot.create(:user) }
    let!(:role) { FactoryBot.create(:role, name: 'admin') }
    let!(:product) { FactoryBot.create(:product) }
    let!(:product_role) { FactoryBot.create(:product_role, product:, role:) }
    let!(:user_product_role) { FactoryBot.create(:user_product_role, product_role:, user:) }

    context 'when the user has the requested role type' do
      it 'returns true' do
        expect(user.is?('admin')).to be true
      end
    end

    context 'when the user does not have the requested role type' do
      it 'returns false' do
        expect(user.is?('editor')).to be false
      end
    end
  end
end
