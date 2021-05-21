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
class TvrPeriodsReviewersController < ApplicationController
  before_action :find_tvr_periods_reviewer, only: [:destroy]

  def create
    @tvr_periods_reviewers = TvrPeriodsReviewers.create(tvr_periods_reviewers_params,
                                                 current_user.username)
    render "create.js"
  rescue => e
    logger.error("Controller:TvrPeriodsReviewers:create:rescuing exception #{e}")
    @error = e.to_s
    render "create_error.js", status: :unprocessable_entity
  end

  def destroy
    username = current_user.username
    if @tvr_periods_reviewer.destroy
      render
    else
      render destroy_error
    end
  end

  private

  def tvr_periods_reviewers_params
    params.require(:tvr_periods_reviewers).permit(:tvr_period_id, :taxonomy_reviewer_id)
  end

  def find_tvr_periods_reviewer
    @tvr_periods_reviewer = TvrPeriodsReviewers.find(delete_params[:id])
  end

  def delete_params
    params.permit(:id)
  end
end
