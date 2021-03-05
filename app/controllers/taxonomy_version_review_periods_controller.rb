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

#   Taxonomy reviews are reviews of tree (taxonomy) versions
class TaxonomyVersionReviewPeriodsController < ApplicationController
  before_action :find_taxonomy_version_review_period, only: [:show, :tab, :update, :destroy, :calendar]

  def index
  end

  def show
    set_tab
    set_tab_index
    @take_focus = params[:take_focus] == 'true'
    calendar_events
    render "show", layout: false
  end

  alias tab show

  def calendar
    calendar_events
  end

  def calendar_events
    @review_days = []
    start_date = @taxonomy_version_review_period.start_date
    end_date = @taxonomy_version_review_period.end_date || start_date + 30
    (start_date..end_date).each do |day|
      case 
      when day === Date.today
      css_class = 'today'
      when day < Date.today
      css_class = 'past-day'
      else
      css_class = 'review-day'
      end
      @review_days.push(
        OpenStruct.new(name: "#{css_class}",start_time: Date.parse(day.to_s))
      )
    end
    #@review_days.push(OpenStruct.new(name: 'today',start_time: Date.today))
  end
  private :calendar_events

  # POST /taxonomy_version_reviews
  def create
    @taxonomy_version_review_period = TaxonomyVersionReviewPeriod.create(
                                taxonomy_version_review_period_params,
                                current_user.username)
    render "create.js"
  rescue => e
    logger.error("Controller:TaxonomyVersionReviewPeriod:create:rescuing exception #{e}")
    @error = e.to_s
    render "create_error.js", status: :unprocessable_entity
  end

  def update
    @message = @taxonomy_version_review_period.update_if_changed(
                 taxonomy_version_review_period_params,
                 current_user.username)
    render "update.js"
  rescue => e
    logger.error("TaxonomyVersionReviewPeriod#update rescuing #{e}")
    @message = e.to_s
    render "update_error.js", status: :unprocessable_entity
  end

  # DELETE 
  def destroy
    username = current_user.username
    if @taxonomy_version_review_period.update_attribute(:updated_by, username) && @taxonomy_version_review_period.destroy
      render
    else
      render js: "alert('Could not delete that record.');"
    end
  end

  private

  def find_taxonomy_version_review_period
    @taxonomy_version_review_period = TaxonomyVersionReviewPeriod.find(params[:id])
    logger.debug("params[:id]: #{params[:id]}")
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "We could not find the record."
    redirect_to taxonomy_version_review_period_path
  end

  def taxonomy_version_review_period_params
    params.require(:taxonomy_version_review_period).permit(:start_date, :end_date, :taxonomy_version_review_id)
  end

  def set_tab
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
