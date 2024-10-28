class Profile::ProfileItem::DefinedQuery::ProductAndProductItemConfigs
  attr_reader :product,
              :instance,
              :product_configs_and_profile_items

  def initialize(instance)
    @product = Profile::Product.find_by(name: "FOA")
    @instance = instance
  end

  def debug(s)
    tag = "Profile::ProfileItem::DefinedQuery::ProductAndProductItemConfigs"
    Rails.logger.debug("#{tag}: #{s}")
  end

  def run_query
    debug("run_query")
    [] unless Rails.configuration.try('foa_profile_aware')
    @product_configs_and_profile_items = find_or_initialize_profile_items
    [product_configs_and_profile_items, product]
  end

  private

  def find_or_initialize_profile_items
    # TODO: Optimise this method!!
    # We may not even need this if we first create the profile item
    # before adding profile texts, references, and annotations.

    # Fetch all product item configs with display_html and associated ProfileItems
    product_item_configs = Profile::ProductItemConfig
      .where.not(display_html: nil)
      .where(product_id: product.id)
      .includes(:profile_items) # Eager load associated profile items

    # Fetch existing profile items for quick lookup
    existing_profile_items = Profile::ProfileItem
      .where(product_item_config_id: product_item_configs.pluck(:id), instance_id: instance.id)
      .index_by(&:product_item_config_id) # Create a hash for O(1) lookup

    # Map the product item configs to their associated profile items
    product_item_configs.map do |product_item_config|
      # Find or initialize the associated ProfileItem
      profile_item = existing_profile_items[product_item_config.id] || Profile::ProfileItem.new(product_item_config: product_item_config, instance_id: instance.id)

      # Return the product item config and associated or newly initialized profile item
      { product_item_config: product_item_config, profile_item: profile_item }
    end
  end
end
