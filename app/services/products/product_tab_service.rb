# service = Products::ProductTabService.call(products) # Now accepts array or single product
#
# Get active flags detected from all products
# service.active_flags # => ['is_name_index', 'is_taxonomic']
#
# Get models enabled by active flags from all products
# service.enabled_models # => [:author, :reference, :name]
#
# Get flag-specific tabs for a model (unified from all products with product names)
# service.available_tabs_for(:author) # => [{ tab: :new, product: product1 }, { tab: :details, product: product2 }]
#
# Get all tabs for all enabled models with product names
# service.all_available_tabs # => { author: [{ tab: :new, product: product1 }], reference: [...] }
#
# Get tabs per product mapping
# service.tabs_per_product # => { product1 => { author: [:new, :edit], reference: [:details] }, ... }
module Products
  class ProductTabService < BaseService

    attr_reader :active_flags, :enabled_models

    def initialize(products, config = ProductTabConfig.new)
      @products = Array(products).compact
      @config = config
      @active_flags = []
      @enabled_models = []
      @result = {}
      @product_tabs = {}
    end

    def execute
      determine_active_flags
      determine_enabled_models
      build_result
      build_product_tabs
      self
    end

    def available_tabs_for(model)
      return [] if model.nil?

      @result[model.to_s] || []
    end

    def tab_options_for(model, tab)
      available_tabs_for(model).find { |t| t[:tab] == tab.to_s }
    end

    def all_available_tabs
      @result
    end

    def tabs_per_product
      @product_tabs
    end

    def show_product_name_for_model?(model)
      return false if model.nil?

      @config.show_product_name_for?(model, @active_flags)
    end

    private

    def determine_active_flags
      return if @products.empty?

      all_flags = Set.new

      @products.each do |product|
        @config.flag_config.keys.each do |flag|
          begin
            all_flags << flag if product.respond_to?(flag) && product.public_send(flag)
          rescue NoMethodError
            Rails.logger.warn("NoMethodError: Product #{product.id} does not have flag #{flag}")
          end
        end
      end

      @active_flags = all_flags.to_a
    end

    def determine_enabled_models
      @enabled_models = @config.enabled_models_for_flags(@active_flags)
    end

    def build_result
      @enabled_models.each do |model|
        @result[model] = []

        @products.each do |product|
          product_flags = determine_flags_for_product(product)
          tabs = @config.tabs_for(model, product_flags)
          show_product_name = @config.show_product_name_for?(model, @active_flags)

          tabs.each do |tab|
            @result[model] << {
              tab: tab,
              product: product,
              show_product_name: show_product_name
            }
          end
        end
      end
    end

    def build_product_tabs
      @products.each do |product|
        product_flags = determine_flags_for_product(product)
        enabled_models = @config.enabled_models_for_flags(product_flags)

        @product_tabs[product] = {}
        enabled_models.each do |model|
          @product_tabs[product][model] = @config.tabs_for(model, product_flags)
        end
      end
    end

    def determine_flags_for_product(product)
      flags = []

      @config.flag_config.keys.each do |flag|
        begin
          flags << flag if product.respond_to?(flag) && product.public_send(flag)
        rescue NoMethodError
          Rails.logger.warn("NoMethodError: Product #{product.id} does not have flag #{flag}")
        end
      end

      flags
    end
  end
end
