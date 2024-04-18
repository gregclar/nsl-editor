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
#

# Provide typeahead suggestions based on a search term.
#
# Offer parents
# Only accepted names
class Loader::Name::Match::AsTypeahead::ForIntendedTreeParentInstance
  attr_reader :suggestions,
              :params

  SEARCH_LIMIT = 50

  def initialize(params)
    @params = params
    @suggestions =
      if @params[:term].blank?
        []
      else
        query
      end
  end

  def prepared_search_term
    @params[:term].tr("*", "%").downcase + "%"
  end

  # Any names ie. not just name on tree
  def alt_core_query
    Instance.joins(:name)
      .joins(:reference)
      .where(['lower(f_unaccent(simple_name)) like lower(f_unaccent(?))',
              prepared_search_term])
      .select("instance.id, name.simple_name, reference.citation")
      .order("simple_name, citation")
      .limit(40)
      .limit(SEARCH_LIMIT)
  end

  # Only names in the draft accepted tree
  def core_query
    Instance.joins(:tree_join_v)
      .joins(:name)
      .where(['lower(f_unaccent(name.simple_name)) like lower(f_unaccent(?))',
              prepared_search_term])
      .where('tree_join_v.accepted_tree = true')
      .where('tree_join_v.instance_id = instance.id')
      .where('tree_join_v.published = false')
      .select("instance.id, name.full_name")
      .order("name.full_name")
      .limit(40)
      .limit(SEARCH_LIMIT)
  end

  def query
    @qry = core_query
    @qry = @qry.select("id")
               .collect do |instance|
      { value: "#{instance.full_name}",
        id: instance.id }
    end
  end
end
