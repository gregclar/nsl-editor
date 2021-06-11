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

#  DiffLists controller is for results from the diff_list(i,j) database function
#
#  Only for showing results of the query on that function
#
#  A diff_list result represents a changed part of the taxonomy, and it can
#  be a new taxon, an altered taxon, or a deleted taxon.  The display has to
#  take those operations into account.
#
class DiffListsController < ApplicationController
  before_action :find_diff_list, only: [:show, :tab]

  def show
    @tab = choose_tab
    @tab_index = choose_index
    @take_focus = params[:take_focus] == 'true'
    #set_up_blank_comment
    logger.debug("params: #{params.inspect}")
    render "show", layout: false
  end

  alias tab show
 
  private

  def find_diff_list
    @diff_list = diff_list_params
    @current_tve = TreeVersionElement.find_by(element_link: @diff_list['current_tve']) unless @diff_list['current_tve'].blank?
    @previous_tve = TreeVersionElement.find_by(element_link: @diff_list['previous_tve']) unless @diff_list['previous_tve'].blank?
    @diff_list['operation'] = 'changed' if @diff_list['operation'] == 'modified'
    #TreeVersionElement.find_by(element_link: params["id"])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "We could not find the diff list item."
    raise
    #redirect_to tree_elements_path
  end

  # ["operation", "previous_tve", "current_tve", "simple_name", "synonyms_html", "name_path"]
  def diff_list_params
    params.permit(:current_tve, :operation, :previous_tve, :current_tve,
                  :simple_name, :format, :tabIndex, :take_focus, :id, :tab)
  end

  def choose_tab
    if params[:tab].present? && params[:tab] != "undefined"
      params[:tab]
    else
      "tab_details"
    end
  end

  def choose_index
    (params[:tabIndex] || "1").to_i
  end

  #def set_up_blank_comment
    #if @tree_version.active_review?
      #if params[:tab] == 'tab_review'
        #@te_comment = TaxonomyElementComment.new
        #@te_comment.tree_element_id = @tree_element.id
        #@te_comment.taxonomy_version_review_period_id = @tree_version.active_review.id
      #else
        #@te_comment = nil
      #end
    #end
  #end
end
