module ProductContextHelper

  def available_contexts_for_current_user
    return [] unless current_registered_user&.available_products_from_roles

    product_context_service.available_contexts.sort_by { |ctx| ctx[:name] }
  end

  def current_context_name
    return "No Context Selected" unless current_context_id

    context = available_contexts_for_current_user.find { |ctx| ctx[:context_id] == current_context_id }
    context ? "Selected Context - #{context[:name]}" : "Invalid Context"
  end

end
