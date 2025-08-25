require "rails_helper"

RSpec.describe TabsHelper, type: :helper do
  let(:product1) { instance_double(Product, name: "FOO") }
  let(:product2) { instance_double(Product, name: "BAR") }
  let!(:mock_product_tab_service) { instance_double(Products::ProductTabService) }
  let(:user) do
    instance_double(
      User,
      available_product_from_roles: product1,
      available_products_from_roles: [product1, product2]
    )
  end

  before do
    allow(mock_product_tab_service).to receive(:tab_options_for).and_return({ show_product_name: true, product: product1 })
    tab_service = mock_product_tab_service
    test_user = user
    helper.define_singleton_method(:current_registered_user) { test_user }
    helper.define_singleton_method(:product_tab_service) { tab_service }
    helper.instance_variable_set(:@tab_index, nil)
    allow(Rails.configuration).to receive(:multi_product_tabs_enabled).and_return(true)
  end

  describe "#user_profile_tab_name" do
    it "returns the name of the user's available product" do
      expect(helper.user_profile_tab_name).to eq(product1.name)
    end
  end

  describe "#user_profile_tab_names" do
    it "returns the names of all user's available products" do
      expect(helper.user_profile_tab_names).to eq(%w[FOO BAR])
    end
  end

  describe "#increment_tab_index" do
    it "increments @tab_index by 1 by default" do
      expect(helper.increment_tab_index).to eq(2)
      expect(helper.increment_tab_index).to eq(3)
    end

    it "increments @tab_index by a given value" do
      expect(helper.increment_tab_index(3)).to eq(4)
    end
  end

  describe "#tab_index" do
    it "returns @tab_index plus offset" do
      helper.increment_tab_index
      expect(helper.tab_index).to eq(2)
      expect(helper.tab_index(2)).to eq(4)
    end

    it "defaults @tab_index to 1 if not set" do
      helper.instance_variable_set(:@tab_index, nil)
      expect(helper.tab_index).to eq(1)
    end
  end

  describe '#product_tab_text' do
    let(:tab_options) { { show_product_name: show_product_name, product: product1 } }

    before do
      allow(mock_product_tab_service).to receive(:tab_options_for)
        .with(:author, 'edit')
        .and_return(tab_options)
    end

    context 'when show_product_name is true' do
      let(:show_product_name) { true }

      it 'returns product name with default text' do
        result = helper.product_tab_text(:author, 'edit', 'Edit')
        expect(result).to eq('FOO Edit')
      end
    end

    context 'when show_product_name is false' do
      let(:show_product_name) { false }

      it 'returns only the default text' do
        result = helper.product_tab_text(:author, 'edit', 'Edit')
        expect(result).to eq('Edit')
      end
    end

    context 'when show_product_name is nil' do
      let(:show_product_name) { nil }

      it 'returns only the default text' do
        result = helper.product_tab_text(:author, 'edit', 'Edit')
        expect(result).to eq('Edit')
      end
    end

    context 'when product is nil' do
      let(:show_product_name) { true }
      let(:tab_options) { { show_product_name: true, product: nil } }

      it 'handles nil product gracefully' do
        result = helper.product_tab_text(:author, 'edit', 'Edit')
        expect(result).to eq('Edit')
      end
    end

    context 'when tab_options_for returns nil' do
      let(:show_product_name) { true }
      before do
        allow(mock_product_tab_service).to receive(:tab_options_for)
          .with(:author, 'edit')
          .and_return(nil)
      end

      it 'returns only the default text' do
        result = helper.product_tab_text(:author, 'edit', 'Edit')
        expect(result).to eq('Edit')
      end
    end
  end

  describe '#tab_available?' do
    let(:tabs_array) { ['details', 'edit', 'comments'] }

    it 'returns true when tab is available' do
      expect(helper.tab_available?(tabs_array, 'edit')).to be true
    end

    it 'returns false when tab is not available' do
      expect(helper.tab_available?(tabs_array, 'missing_tab')).to be false
    end

    it 'handles empty tabs array' do
      expect(helper.tab_available?([], 'edit')).to be false
    end

    context "when feature flag is off" do
      before do
        allow(Rails.configuration).to receive(:multi_product_tabs_enabled).and_return(false)
      end

      it "returns true when tab is available" do
        expect(helper.tab_available?(tabs_array, 'edit')).to be true
      end

      it "returns true when tab is not available" do
        expect(helper.tab_available?(tabs_array, 'missing_tab')).to be true
      end

      it "handles empty tabs array" do
        expect(helper.tab_available?([], 'edit')).to be true
      end
    end
  end

end
