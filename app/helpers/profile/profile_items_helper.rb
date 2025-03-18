# Help display profile_item information.
module Profile::ProfileItemsHelper
  def sourced_in_profile_items_info(profile_item)
    return unless profile_item.sourced_in_profile_items.present?

    count = profile_item.sourced_in_profile_items.count
    content_tag(:div, style: "padding: 10px;") do
      "This item is cited by #{ActionController::Base.helpers.pluralize(count, 'other item')}."
    end
  end
end
