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
class Tree::ElementsController < ApplicationController
  before_action :find_tree_element, only: [:show, :tab, :update_profile]

  # GET /tree_vesions/1
  # GET /tree_vesions/1/tab/:tab
  # Sets up RHS details panel on the search results page.
  # Displays a specified or default tab.
  def show
    @tab = choose_tab
    @tab_index = choose_index
    @take_focus = params[:take_focus] == 'true'
    @tree_version = TreeVersion.find(params['tree-version-id'])
    logger.debug("params: #{params.inspect}")
    render "show", layout: false
  end

  alias tab show

  def update_profile
    @refresh = false
    @distribution_message = 'No distribution change'
    @comment_message = 'No comment change'
    scope = 'Distribution'
    update_distribution
    scope = 'Comment'
    @comment_message, @refresh = @tree_element.update_comment(
      tree_element_params[:comment_value].gsub(/\n/,' ').strip,
      @current_user.username)
  rescue => e
    logger.error("Tree::ElementsController:update_profile:rescuing #{scope} exception #{e}")
    @message = "#{scope} update error: #{e}"
    render :update_profile_error, status: :unprocessable_entity
  end

  private

  def update_distribution
    if @tree_element.excluded?
      ActiveRecord::Base.transaction do
        update_excluded_distribution
      end
    else
      ActiveRecord::Base.transaction do
        update_accepted_distribution
      end
    end
  end

  def update_excluded_distribution
    if tree_element_params[:distribution_value].blank?
      @distribution_message = ''
    else
      throw 'Distribution changes for excluded names not implemented'
    end
  end

  def update_accepted_distribution
    if tree_element_params[:distribution_value].blank?
      if @tree_element.profile.blank?
        @distribution_message = 'Empty distribution for empty profile - nothing to do'
      elsif @tree_element.distribution_value.blank?
        @distribution_message = 'No distribution change'
      else
        @distribution_message = 'You want to delete the distribution'
        @tree_element.remove_distribution_directly
        te = Tree::Element.find(@tree_element.id)
        te.delete_tedes
        @distribution_message = 'Distribution removed'
        @refresh = true
      end
    else # dist param exists
      if @tree_element.profile.blank?
        @distribution_message = "Adding a profile to hold a new distribution"
        new_cleaned = Tree::Element.cleanup_distribution_string(tree_element_params[:distribution_value])
        Tree::Element.validate_distribution_string(new_cleaned)
        @tree_element.add_profile_with_distribution_directly(
          @current_user.username, 
          new_cleaned)
        te = Tree::Element.find(@tree_element.id)
        te.apply_string_to_tedes
        @distribution_message = "Distribution added to a fresh profile"
        @refresh = true
      elsif @tree_element.distribution_value.blank?
        @distribution_message = "Adding a distribution to an existing profile"
        new_cleaned = Tree::Element.cleanup_distribution_string(tree_element_params[:distribution_value])
        Tree::Element.validate_distribution_string(new_cleaned)
        @tree_element.add_profile_distribution_directly(
          @current_user.username, 
          new_cleaned)
        te = Tree::Element.find(@tree_element.id)
        te.apply_string_to_tedes
        @distribution_message = "Distribution added"
        @refresh = true
      elsif @tree_element.distribution_value != tree_element_params[:distribution_value]
        @distribution_message = 'Distribution has changed'

        new_cleaned = Tree::Element.cleanup_distribution_string(tree_element_params[:distribution_value])
        if new_cleaned == @tree_element.distribution_value
          @distribution_message =
            'No change in standardardised format of accepted taxon distribution'
        else
          Tree::Element.validate_distribution_string(new_cleaned)
          @tree_element.update_distribution_directly(new_cleaned, @current_user.username)
          te = Tree::Element.find(@tree_element.id)
          te.apply_string_to_tedes
          @refresh = true
          @distribution_message = 'Distribution changed'
        end
      else 
        @distribution_message = "No change to distribution"
      end
    end
  end

  def find_tree_element
    @tree_element = Tree::Element.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "We could not find the tree element."
    redirect_to tree_elements_path
  end

  def tree_element_params
    params.require(:tree_element).permit(:draft_name, :distribution_value,
                                        :comment_value)
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
end


