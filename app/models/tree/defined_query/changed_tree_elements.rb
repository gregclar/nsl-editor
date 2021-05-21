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
 


#   A defined query is one that the Search class knows about and can run.
#   
#   Run SQL to retrieve changed tree elements - that is, changed from one
#   tree version to another later tree version.
#
#   Expect parameter string of 2 tree version ids separated by a comma.
#   e.g. 51358658,51357890
#
#   It counts as 1 param, but here we split it on the comma.
#   
class Tree::DefinedQuery::ChangedTreeElements
  attr_reader :results,
              :limited,
              :common_and_cultivar_included,
              :has_relation,
              :relation,
              :count,
              :show_csv,
              :total

  SQL = <<HERE
select regexp_replace(current_tve,'.*\/','') id,
       regexp_replace(regexp_replace(current_tve,'\/tree\/',''),'\/.*','') tv_id,
       simple_name,
       case operation
         when 'modified' then 'changed'
         else operation
       end,
       synonyms_html,
       name_path,
       current_tve,
       previous_tve,
       ? tv_id_param
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

  
  def prepare_sql_old
    # SQL.sub('?', @tree_version_1).sub('?', @tree_version_2).sub('?', @tree_version_1)
    sql = <<-HERE
select regexp_replace(current_tve,'.*\/','') id,
       regexp_replace(regexp_replace(current_tve,'\/tree\/',''),'\/.*','') tv_id,
       simple_name,
       case operation
         when 'modified' then 'changed'
         else operation
       end,
       synonyms_html,
       name_path,
       current_tve,
       previous_tve,
       '#{@tree_version_1}' tv_id_param
       from diff_list(@tree_version_1,@tree_version_2)
HERE
  end

  def query_on_table_function
    arel_table = DiffList.arel_table
    sql = arel_table.project(arel_table[Arel.star]).to_sql
    sql = sql + "(#{@tree_version_2},#{@tree_version_1})"
    Rails.logger.debug(sql)
    ActiveRecord::Base.connection.exec_query(sql)
  end

  def list_query
    #list_query_via_tree_element
    list_query_via_diff_list
  end

  def list_query_via_tree_element
    Rails.logger.debug(" list_query_via_tree_element ==============================================")
    @results = TreeElement.find_by_sql([SQL,@tree_version_1,@tree_version_2,@tree_version_1])
    Rails.logger.debug(@results.class)

    add_context_to_results
    @limited = @common_and_cultivar_included = true
    @count = @results.size
    @has_relation = false
    @relation = nil
  end

  def list_query_via_diff_list
    Rails.logger.debug("==============================================")
    @results = query_on_table_function
    Rails.logger.debug(@results.class)
    Rails.logger.debug(@results.try('columns'))
    # ["operation", "previous_tve", "current_tve", "simple_name", "synonyms_html", "name_path"]
    @results = @results.to_a
    @results = @results.each do |r|
      r[:display_as] = 'DiffListRecord'
      r[:id] = r[:current_tve]
      r[:fresh] = false
    end
    Rails.logger.debug(@results.class)

    add_context_to_results
    @limited = @common_and_cultivar_included = true
    @count = @results.size
    @has_relation = false
    @relation = nil
  end

  def add_context_to_results
    push_tree_version_onto_results
    push_tree_onto_results
  end

  def push_tree_version_onto_results
    tv_results = TreeVersion.where(id: @tree_version_1)
    @results.unshift(*tv_results)
  end

  def push_tree_onto_results
    tree_results= Tree.all
    @results.unshift(*tree_results)
  end

  def csv?
    @show_csv
  end
end
