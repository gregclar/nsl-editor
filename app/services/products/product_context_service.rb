module Products
  class ProductContextService < BaseService

    attr_reader :products

    def initialize(products:, params: nil)
      super(params)
      @products = products
    end

    def execute
      available_contexts
    end

    def available_contexts
      @available_contexts ||= products.blank? ? [] : query_product_context.select { |ctx| (ctx[:products] & products).any? }
    end

    private

    def query_product_context
      ProductContext
        .includes(:product)
        .group_by(&:context_id)
        .transform_values { |contexts| contexts.map(&:product).map(&:name).join('/') }
        .sort
        .to_h
        .map do |context_id, context_list|
        {
          context_id: context_id,
          name: context_list,
          description: context_list,
          products: products_for_context(context_id)
        }
      end.uniq{|ctx| ctx[:context_id]}
    end

    def products_for_context(context_id)
      Product.for_context(context_id)
    end
  end
end
