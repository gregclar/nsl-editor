require 'rails_helper'

RSpec.describe Products::ProductContextService do
  let!(:product_1) { create(:product, name: "APC", context_id: 1, context_sort_order: 1) }
  let!(:product_2) { create(:product, name: "APNI", context_id: 1, context_sort_order: 3) }
  let!(:product_3) { create(:product, name: "FOA", context_id: 2, context_sort_order: 2) }

  subject(:service) { described_class.new(products: [product_1, product_2, product_3]) }

  describe ".initialize" do
    it "sets products" do
      expect(service.products).to eq([product_1, product_2, product_3])
    end
  end

  describe "#execute" do
    it "returns available contexts based on products" do
      result = service.execute
      expect(result.length).to eq(2)
    end

    it "returns the correct context names and descriptions" do
      result = service.execute
      context_names = result.map { |ctx| ctx[:name] }
      expect(context_names).to include("#{product_1.name}/#{product_2.name}", product_3.name)
    end

    it "returns products ordered by context_sort_order within each context" do
      result = service.execute
      apc_apni_context = result.find { |ctx| ctx[:context_id] == 1 }
      foa_context = result.find { |ctx| ctx[:context_id] == 2 }

      expect(apc_apni_context[:products].map(&:name)).to eq([product_1.name, product_2.name])
      expect(foa_context[:products].map(&:name)).to eq([product_3.name])
    end

    it "sets the available_products instance variable" do
      result = service.execute
      expect(service.available_contexts.length).to eq(2)
    end

    context "when no products are provided" do
      subject(:empty_service) { described_class.new(products: []) }

      it "returns an empty array" do
        expect(empty_service.execute).to eq([])
      end
    end
  end
end
