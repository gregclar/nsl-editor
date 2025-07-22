require "rails_helper"

RSpec.describe TabsHelper, type: :helper do
  let(:product1) { double(name: "FOO") }
  let(:product2) { double(name: "BAR") }

  before do
    user =  double(
      available_product_from_roles: product1,
      available_products_from_roles: [product1, product2]
    )
    helper.define_singleton_method(:current_registered_user) { user }
    helper.instance_variable_set(:@tab_index, nil)
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
end
