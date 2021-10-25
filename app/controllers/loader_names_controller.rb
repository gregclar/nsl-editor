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
class LoaderNamesController < ApplicationController
  before_action :find_loader_name, only: [:show, :destroy, :tab]

  # Sets up RHS details panel on the search results page.
  # Displays a specified or default tab.
  def show
    set_tab
    set_tab_index
    @take_focus = params[:take_focus] == 'true'
    render "show", layout: false
  end

  alias tab show

  def new_row
    @random_id = (Random.new.rand * 10_000_000_000).to_i
    respond_to do |format|
      format.html { redirect_to new_search_path }
      format.js {}
    end
  end

  private

  def find_loader_name
    @loader_name = LoaderName.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "We could not find the loader name record."
    redirect_to loader_names_path
  end

  def loader_name_params
    params.require(:loader_name).permit(:scientific_name)
  end

  def set_tab
    logger.debug('set_tab')
    logger.debug('set_tab')
    logger.debug('set_tab')
    logger.debug('set_tab')
    logger.debug('set_tab')
    logger.debug('set_tab')
    logger.debug('set_tab')
    logger.debug('set_tab')
    logger.debug("set_tab params[:tab]: #{params[:tab]}")
    @tab = if params[:tab].present? && params[:tab] != "undefined"
             params[:tab]
           else
             "tab_details"
           end
  end

  def set_tab_index
    @tab_index = (params[:tabIndex] || "1").to_i
  end
end
