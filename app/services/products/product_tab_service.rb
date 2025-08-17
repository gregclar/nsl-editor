# service = Products::ProductTabService.call(product)
#
# Get active flags detected from product
# service.active_flags # => ['is_name_index']
#
# Get models enabled by active flags
# service.enabled_models # => [:author, :reference]
#
# Get flag-specific tabs for a model
# service.available_tabs_for(:author) # => [:new, :details, :edit, :comments]
#
# Get all tabs for all enabled models
# service.all_available_tabs # => { author: [...], reference: [...] }
module Products
  class ProductTabService < BaseService

    attr_reader :active_flags, :enabled_models

    def initialize(product, config = ProductTabConfig.new)
      @product = product
      @config = config
      @active_flags = []
      @enabled_models = []
      @result = {}
    end

    def execute
      determine_active_flags
      determine_enabled_models
      build_result
      self
    end

    def available_tabs_for(model)
      return [] if model.nil?

      @result[model.to_s] || []
    end

    def all_available_tabs
      @result
    end

    def show_product_name_for_model?(model)
      return false if model.nil?

      @config.show_product_name_for?(model, @active_flags)
    end

    private

    def determine_active_flags
      return unless @product

      @config.flag_config.keys.each do |flag|
        begin
          @active_flags << flag if @product.respond_to?(flag) && @product.public_send(flag)
        rescue NoMethodError
          Rails.logger.warn("NoMethodError: Product #{@product.id} does not have flag #{flag}")
        end
      end
    end

    def determine_enabled_models
      @enabled_models = @config.enabled_models_for_flags(@active_flags)
    end

    def build_result
      @enabled_models.each do |model|
        @result[model] = @config.tabs_for(model, @active_flags)
      end
    end
  end
end
