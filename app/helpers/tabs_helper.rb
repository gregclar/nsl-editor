# frozen_string_literal: true

#   Copyright 2015 Australian National Botanic Gardens
#
#   This file is part of the NSL Editor.
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

# Help for Tabs display
module TabsHelper
  def user_profile_tab_name
    current_registered_user.available_product_from_roles&.name
  end

  def increment_tab_index(increment = 1)
    @tab_index ||= 1
    @tab_index += increment
  end

  def tab_index(offset = 0)
    tabi = @tab_index || 1
    tabi + offset
  end

  def product_tab_text(entity_type, tab_type, default_text)
    return default_text unless Rails.configuration.try('multi_product_tabs_enabled')

    options = product_tab_service.tab_options_for(entity_type, tab_type)
    return default_text if options.nil?

    if should_show_product_name_for_tab?(entity_type, tab_type)
      tab_text = "#{options.dig(:product)&.name} #{default_text}"
      tab_text.strip
    else
      default_text
    end
  end

  def tab_available?(tabs_array, tab_name)
    return true unless Rails.configuration.try('multi_product_tabs_enabled')
    return true if product_context_service.available_contexts.blank?

    tabs_array.include?(tab_name)
  end

  private

  def should_show_product_name_for_tab?(entity_type, tab_type)
    return false unless context_has_multiple_products?

    products_providing_tab = products_in_current_context.select do |product|
      product_provides_tab_for_model?(product, entity_type, tab_type)
    end

    products_providing_tab.count > 1
  end

  def context_has_multiple_products?
    products_in_current_context.count > 1
  end

  def products_in_current_context
    return [] unless current_context_id

    @products_in_current_context ||= ProductContext
      .where(context_id: current_context_id)
      .includes(:product)
      .map(&:product)
  end

  def product_provides_tab_for_model?(product, entity_type, tab_type)
    service = Products::ProductTabService.call(product)
    available_tabs = service.available_tabs_for(entity_type)
    available_tabs.any? { |tab_obj| tab_obj[:tab] == tab_type.to_s }
  end
end
