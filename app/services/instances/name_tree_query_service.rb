module Instances
  class NameTreeQueryService < BaseService
    attr_reader :instance, :name_trees

    def initialize(instance:, params: {})
      super(params)
      @instance = instance
    end

    def execute
      @name_trees ||= Instance
        .joins('INNER JOIN tree_element ON instance.id = tree_element.instance_id')
        .joins('JOIN tree_version_element tve ON tree_element.id = tve.tree_element_id')
        .joins('JOIN tree t ON tve.tree_version_id = t.current_tree_version_id')
        .where(id: @instance.id)
        .where('t.is_read_only = false')
        .group('instance.id, t.name')
        .select(Arel.sql("instance.id, string_agg(t.name, ', ' ORDER BY t.name) AS name"))
    end
  end
end
