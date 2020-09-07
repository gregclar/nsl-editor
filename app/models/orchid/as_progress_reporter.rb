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


#  We need to place Orchids on a draft tree.
class Orchid::AsProgressReporter
  def initialize(taxon_string)
    @taxon_string = taxon_string.downcase.gsub(/\*/,'%')
  end

  def progress_report
    { search: {search_string: @taxon_string},
      core: { accepted: accepteds,
              synonym: synonyms,
              misapplied: misapplieds,
              hybrid_cross: hybrid_crosses,
              total: orchids_and_their_synonyms },
      matched: { accepted_with_preferred_match: accepted_with_preferred_match,
                  synonym_with_preferred_match: synonym_with_preferred_match,
                  misapplied_with_a_preferred_match: misapplied_with_a_preferred_match,
                  misapplied_preferred_matches: misapplied_preferred_matches },
      unmatched: { accepted_without_preferred_match: accepted_without_preferred_match,
                   synonym_without_preferred_match: synonym_without_preferred_match,
                   misapplied_without_a_preferred_match: misapplied_without_a_preferred_match },
      with_match_and_instances:
        { accepted_matched_with_standalone: accepted_matched_with_standalone,
          synonym_matched_with_cross_ref: synonym_matched_with_cross_ref,
          misapplied_with_cross_ref: misapplied_with_cross_ref },
      with_match_but_without_instances:
        { accepted_matched_without_standalone: accepted_matched_without_standalone,
          synonym_matched_without_cross_ref: synonym_matched_without_cross_ref,
          misapplied_matched_without_cross_ref: misapplied_matched_without_cross_ref },
      taxonomy: in_taxonomy,
      other: { further_processing_prevented: further_processing_prevented },
    }
  end

  def core_search
    Orchid.taxon_string_search(@taxon_string)
  end

  def orchids_and_their_synonyms
    core_search.count
  end

  def accepteds
    core_search.where("record_type = 'accepted'") .count
  end

  def synonyms
    core_search.where("record_type = 'synonym'") .count
  end

  def misapplieds
    core_search.where("record_type = 'misapplied'") .count
  end

  def hybrid_crosses
    core_search.where("record_type = 'hybrid_cross'") .count
  end

  def further_processing_prevented
    core_search.where(" exclude_from_further_processing  or (select exclude_from_further_processing from orchids p where p.id = orchids.parent_id)")
           .count
  end

  def accepted_with_preferred_match
    Orchid.where("lower(taxon) like '#{@taxon_string}' and record_type = 'accepted'")
          .joins(:orchids_name)
          .count
  end

  def accepted_without_preferred_match
    core_search.where("record_type = 'accepted'")
          .where.not("exists (select null from orchids_names orn where orchids.id = orn.orchid_id)")
          .count
  end

  def synonym_with_preferred_match
    core_search.where("record_type = 'synonym'")
               .joins(:orchids_name)
               .count
  end

  def synonym_without_preferred_match
    core_search.where("record_type = 'synonym'")
               .where.not("exists (select null from orchids_names orn where orchids.id = orn.orchid_id)")
               .count
  end

  def misapplied_preferred_matches
    core_search.where("record_type = 'misapplied'")
               .joins(:orchids_name)
               .count
  end

  def misapplied_with_a_preferred_match
    core_search.where("record_type = 'misapplied'")
               .where("exists (select null from orchids_names orn where orchids.id = orn.orchid_id)")
               .count
  rescue => e
    e.to_s
  end

  def misapplied_without_a_preferred_match
    core_search.where("record_type = 'misapplied'")
               .where.not("exists (select null from orchids_names orn where orchids.id = orn.orchid_id)")
               .count
  rescue => e
    e.to_s
  end

  def accepted_matched_with_standalone
    core_search.where("record_type = 'accepted'")
               .joins(:orchids_name)
               .where.not( {orchids_names: { standalone_instance_id: nil}})
               .count
  end

  def accepted_matched_without_standalone
    core_search.where("record_type = 'accepted'")
               .joins(:orchids_name)
               .where( {orchids_names: { standalone_instance_id: nil}})
               .count
  end

  def synonym_matched_with_cross_ref
    core_search.where("record_type = 'synonym'")
               .joins(:orchids_name)
               .where.not( {orchids_names: { relationship_instance_id: nil}})
               .count
  end

  def synonym_matched_without_cross_ref
    core_search.where("record_type = 'synonym'")
               .joins(:orchids_name)
               .where( {orchids_names: { relationship_instance_id: nil}})
               .count
  end

  def misapplied_with_cross_ref
    core_search.where("record_type = 'misapplied'")
               .joins(:orchids_name)
               .where.not( {orchids_names: { relationship_instance_id: nil}})
               .count
  end

  def misapplied_matched_without_cross_ref
    core_search.where("record_type = 'misapplied'")
               .joins(:orchids_name)
               .where( {orchids_names: { relationship_instance_id: nil}})
               .count
  end

  # Note: the name_id column is merely an ugly hack to get the count(*) value.
  # It is _not_ the name_id
  def xin_taxonomy
    sql = "select t.draft_name, count(*) name_id "
    sql += " from orchids_names orn "
    sql += " join orchids o "
    sql += " on o.id = orn.orchid_id "
    sql += " join tree_vw t "
    sql += " on orn.standalone_instance_id = t.instance_id "
    sql += " where lower(o.taxon) like ? "
    sql += " group by t.draft_name, published, case o.record_type when 'misapplied' then 3 when 'synonym' then 2 when 'accepted' then 1 else 99 end "
    sql += " order by case o.record_type when 'misapplied' then 3 when 'synonym' then 2 when 'accepted' then 1 else 99 end, 2 "
    records_array = TreeVw.find_by_sql([sql, @taxon_string])
    h = {}
    records_array.each do |rec|
      h[rec[:draft_name]] = rec[:name_id]
    end
    h
  end

  # Note: the name_id column is merely an ugly hack to get the count(*) value.
  # It is _not_ the name_id
  def in_taxonomy
    sql = "select t.draft_name, count(*) name_id "
    sql += " from orchids_names orn "
    sql += " join orchids o "
    sql += " on o.id = orn.orchid_id "
    sql += " join tree_vw t "
    sql += " on orn.standalone_instance_id = t.instance_id "
    sql += " where lower(o.taxon) like ? "
    sql += " group by t.draft_name, published"
    records_array = TreeVw.find_by_sql([sql, @taxon_string])
    h = {}
    records_array.each do |rec|
      h[rec[:draft_name]] = rec[:name_id]
    end
    h
  end
end
