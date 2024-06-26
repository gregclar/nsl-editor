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
#
# Build a loader_name bulk search query based on a search string
# Based on Loader::Name::BulkSearch
#
# Don't care about accepted or excluded - the names must have a preferred match
# and if they have a preferred match we will deal with them.
#
# Only works for simple_name match
class Loader::Name::BulkSynConflictsSearch
  attr_reader :search

  def initialize(search_s, batch_id)
    @search_s = search_s
    @batch_id = batch_id
    bulk_processing_search
  end

  # For the accepted, draft tree
  # within a nominated batch
  # there is an instance on that tree
  # and that instance has a name identified in a loader_name_match
  # and the loader_name_match is for a loader_name
  # and the name's name status is legitimate or n/a
  # in a nominated batch
  # and the preferred match is not a partial relationship instance type
  def bulk_processing_search
    @search = TreeJoinV
    .joins(" inner join instance on instance.id = tree_join_v.instance_id")
    .joins(" inner join name on instance.name_id = name.id")
    .joins(" inner join loader_name_match on loader_name_match.name_id = name.id")
    .joins(" inner join instance_type on instance_type.id = loader_name_match.relationship_instance_type_id")
    .joins(" inner join loader_name on loader_name.id = loader_name_match.loader_name_id")
    .joins(" inner join loader_batch on loader_batch.id = loader_name.loader_batch_id")
    .where(" loader_name.loader_batch_id = ? ", @batch_id)
    .where(" loader_name.record_type = 'synonym' ")
    .where(" loader_name.synonym_type not like '%partial%' ")
    .where(" not instance_type.pro_parte ")
    .where(" loader_name.partly is null ")
    .where(" tree_join_v.published = false ")
    .where(" tree_join_v.accepted_tree = true ")
    .where(" tree_join_v.name_id = name.id ")
    .select(" tree_join_v.*, loader_name.id loader_name_id ")
    loader_name_restriction
  end

  def loader_name_restriction
    if @search_s.match(/\Afamily:.*\z/)
      family_search
    else
      @search = @search.where(" lower(loader_name.simple_name) like lower(?)",
           @search_s.downcase.gsub(/\*/,'%'))
    end
  end

  # Family clause can be like this
  #
  #     family: one-family-name*
  #
  # which can have wildcard because converted to SQL like
  #
  #     family like 'one-family-name%'
  #
  # But a family clause ike this -
  #
  #     family: one-family-name, another-family-name, yet-another
  #
  # cannot have wildcards because they get converted to SQL like this
  #
  #     family in ('one-family-name', 'another-family-name', 'yet-another')
  #
  def family_search
    @family_s = @search_s.downcase.sub(/ *family: */,'')
    if @family_s.split(/ *, */).size < 2
      one_family_search
    else
      families_search
    end
  end

  def one_family_search
    @search = @search.where(" lower(loader_name.family) like lower(?)",
                            @family_s.gsub(/\*/,'%'))
  end

  def families_search
    @search = @search.where(" lower(loader_name.family) in (?)",
                      @family_s.split(",").collect(&:strip))
  end
end
