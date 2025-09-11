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

    context "for multiple contexts" do
      let!(:product_context_service) do
        instance_double(
          Products::ProductContextService,
          available_contexts: [
            {name: product_context.name, context_id: 3},
            {name: product_context.name, context_id: 1},
            {name: product_context.name, context_id: 2}
          ]
        )
      end

      it "sorts contexts by context_id" do
        expect(helper.available_contexts_for_current_user.collect{|context| context[:context_id]}).to eq([1, 2, 3])
      end
    end

  end
end
