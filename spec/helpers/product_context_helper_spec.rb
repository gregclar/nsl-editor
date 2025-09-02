require "rails_helper"

RSpec.describe ProductContextHelper, type: :helper do
  let!(:product) { instance_double(Product, name: "FOO") }
  let!(:user) do
    instance_double(User, available_products_from_roles: [product])
  end
  let!(:product_context) { instance_double(ProductContext, name: "context-name", context_id: 1)}
  let!(:product_context_service) do
    instance_double(
      Products::ProductContextService,
      available_contexts: [{name: product_context.name, context_id: product_context.context_id}]
    )
  end

  before do
    test_user = user
    test_product_context_service = product_context_service
    test_product_context = product_context

    helper.define_singleton_method(:current_registered_user) { test_user }
    helper.define_singleton_method(:product_context_service) { test_product_context_service }
    helper.define_singleton_method(:current_context_id) { test_product_context.context_id }
  end

  describe "#available_contexts_for_current_user" do
    it "returns the names of available contexts" do
      expect(helper.available_contexts_for_current_user).to eq([{name: product_context.name, context_id: product_context.context_id}])
    end
  end

  describe "#current_context_name" do
    it "returns the name of the current context" do
      expect(helper.current_context_name).to eq("Selected Context - #{product_context.name}")
    end

    context "when no current context" do
      before do
        allow(helper).to receive(:current_context_id).and_return(nil)
      end

      it "returns 'No Context Selected'" do
        expect(helper.current_context_name).to eq("No Context Selected")
      end
    end

    context "for invalid context" do
      before do
        allow(helper).to receive(:current_context_id).and_return("some-invalid-id")
      end

      it "returns 'Invalid Context'" do
        expect(helper.current_context_name).to eq("Invalid Context")
      end
    end
  end
end
