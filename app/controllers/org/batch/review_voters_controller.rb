
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
class Org::Batch::ReviewVotersController < ApplicationController
  before_action :find_org_batch_review_voter, only: %i[destroy]

  def create
    @org_batch_review_voter = Org::Batch::ReviewVoter.create(review_voter_params,
                                                             current_user.username)
    render "create"
  rescue StandardError => e
    logger.error("Controller:Org::Batch::ReviewVotersController:create:rescuing exception #{e}")
    @error = e.to_s
    render "create_error", status: :unprocessable_entity
  end

  def destroy
    Rails.logger.debug('destroy')
    @org_batch_review_voter.destroy
  end

  private

  def find_org_batch_review_voter
    Rails.logger.debug('find_org_batch_review_voter')
    @org_batch_review_voter = Org::Batch::ReviewVoter.where(batch_review_id: params[:batch_review_id]).where(org_id: params[:org_id]).try('first')
  #rescue ActiveRecord::RecordNotFound
    #flash[:alert] = "We could not find the org batch review voter record."
    #redirect_to org_batch_review_voters_path
  end

  def review_voter_params
    params.require(:org_batch_review_voter).permit(:batch_review_id, :org_id)
  end
end
