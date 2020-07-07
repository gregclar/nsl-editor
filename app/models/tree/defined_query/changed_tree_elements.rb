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
#   A defined query is one that the Search class knows about and may
#   instantiate.
#   
#   Run SQL to retrieve changed tree elements - that is, changed from one
#   tree version to another later tree version.
#
#   Expect parameter string of 2 tree version ids separated by a comma.
#   e.g. 51358658,51357890
#
#   It counts as 1 param, but here we split it on the comma.
class Tree::DefinedQuery::ChangedTreeElements
  attr_reader :results,
              :limited,
              :common_and_cultivar_included,
              :has_relation,
              :relation,
              :count,
              :show_csv,
              :total

  SQL1 = <<HERE
  select fred.te_id as id,
       fred.simple_name,
       fred.operation,
       fred.synonyms,
       fred.synonyms_html,
       tve.name_path,
       tv.id tv_id,
       tve.element_link tve_element_link
  from tree_version_element tve
      join (
    select * from find_all_changes(?,?)) fred
    on fred.te_id = tve.tree_element_id
    and fred.tree_version_id = tve.tree_version_id
      join tree_version tv 
      on fred.tree_version_id = tv.id
union
select fred.te_id,
       fred.simple_name,
       fred.operation,
       fred.synonyms,
       fred.synonyms_html,
       'A: no name path',
       tv.id tv_id,
       'no element link'
  from tree_version tv
      join (
    select * from find_all_changes(?,?) where operation = 'removed') fred
      on fred.tree_version_id = tv.id
 where fred.operation = 'removed'
order by name_path
HERE

# fred.te_id as id,                    get out of current tve - the final integer
# fred.simple_name,                    yes
# fred.operation,                      yes
# fred.synonyms,
# fred.synonyms_html,                  yes
# tve.name_path,                       yes
# tv.id tv_id,                         get out of current tve - the first integer
# tve.element_link tve_element_link    no


  SQLP1 = "select * from diff_list(?,?)"
  # Cols:
  # operation     | modified
  # previous_tve  | /tree/51357890/51357029
  # current_tve   | /tree/51344953/51210425
  # simple_name   | Cycas lane-poolei
  # synonyms_html | ...
  # name_path     | ...
   
  # ActionController::UrlGenerationError in Search#search 
  # SQL = "select id, simple_name, operation, synonyms, synonyms_html, name_path, tv_id, tve_element_link from diff_list(?,?)"
  # SQL = "select id, simple_name, operation, synonyms, synonyms_html, name_path, tv_id, tve_element_link from diff_list(?,?)"

  SQL = <<HERE
select regexp_replace(current_tve,'.*\/','') id,
       regexp_replace(regexp_replace(current_tve,'\/tree\/',''),'\/.*','') tv_id,
       simple_name,
       case operation
         when 'modified' then 'changed'
         else operation
       end,
       synonyms_html,
       name_path
       from diff_list(?,?)
HERE

  def initialize(parsed_request)
    debug("start")
    @parsed_request = parsed_request
    run_query
  end

  def debug(s)
    tag = "Tree::DefinedQuery::ChangedTreeElements"
    Rails.logger.debug("#{tag}: #{s}")
  end

  def run_query
    debug("run_query")
    build_args
    validate_args
    @show_csv = false
    #if @parsed_request.count
    #  count_query
    #else
      list_query
    #end
    @total = nil
  end

  def build_args
    @args = @parsed_request.where_arguments.split(",")
    raise "Exactly 2 reference IDs are expected in @args: #{@args}." unless @args.size == 2
    @tree_version_1 = @args.first.to_i
    @tree_version_2 = @args.last.to_i
  end

  def validate_args
    debug("validate_args")
    raise "ID:#{@args.first} is not a tree version id" unless TreeVersion.exists?(@tree_version_1)
    raise "ID:#{@args.last} is not a tree version id" unless TreeVersion.exists?(@tree_version_2)
    #raise "No Reference ID:#{@args.last}" unless Reference.exists?(@ref_id_2)
  end

  def count_query
    instances = Instance.for_ref(@ref_id_1)
                        .for_ref_and_correlated_on_name_id(@ref_id_2)
    @count = instances.size
    @results = []
    @limited = false
    @common_and_cultivar_included = true
    @has_relation = false
    @relation = nil
  end

  def list_query
    debug('list_query')
    # @results = TreeElement.find_by_sql([SQL,@tree_version_1,@tree_version_2,@tree_version_1,@tree_version_2])
    @results = TreeElement.find_by_sql([SQL,@tree_version_1,@tree_version_2])
    tree_results= Tree.all
    tv_results = TreeVersion.where(id: @tree_version_1)
    @results.unshift(*tv_results)
    @results.unshift(*tree_results)
    # debug(@results.class)
    # @results.each {|result| debug(result)}
    @limited = true
    @common_and_cultivar_included = true
    @count = @results.size
    @has_relation = false
    @relation = nil
  end

  def csv?
    @show_csv
  end
end
