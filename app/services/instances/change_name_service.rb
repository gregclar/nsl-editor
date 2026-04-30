# frozen_string_literal: true
module Instances
  class ChangeNameService < BaseService
    def initialize(instance:, new_name_id:, username:)
      super({})
      @instance = instance
      @new_name_id = new_name_id.to_i
      @username = username
    end

    def execute
      new_name = Name.find(@new_name_id)

      if synonym_name_ids.include?(@new_name_id)
        return errors.add(:base, "#{new_name.full_name} is listed as a synonym of this instance.")
      end

      unless new_name.name_type_id == @instance.name.name_type_id &&
             new_name.name_rank_id == @instance.name.name_rank_id
        return errors.add(:base, "The selected name must be the same type and rank as the current name.")
      end

      @instance.name_change_permitted = true
      @instance.name_id = @new_name_id
      @instance.updated_by = @username
      @instance.save
      errors.merge!(@instance.errors) if @instance.errors.any?
    end

    private

    def synonym_name_ids
      Instance.where(cited_by_id: @instance.id).where.not(cites_id: nil).pluck(:name_id)
    end
  end
end
