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

#  A tvr-periods-reviewers
class TvrPeriodsReviewers < ActiveRecord::Base
  strip_attributes
  self.table_name = "tvr_periods_reviewers"
  self.primary_key = "id"
  belongs_to :period, class_name: "TaxonomyVersionReviewPeriod", foreign_key: "tvr_period_id", optional: false
  belongs_to :reviewer, class_name: "TaxonomyReviewer", foreign_key: "taxonomy_reviewer_id", optional: false
  validates :tvr_period_id, presence: true
  validates :taxonomy_reviewer_id, uniqueness: { scope: :tvr_period_id, message: "already allocated to this period" }
  
  def display_as
    'TvrPeriodsReviewers'
  end

  def self.create(params, username)
    tvr_periods_reviewers = TvrPeriodsReviewers.new(params)
    if tvr_periods_reviewers.save_with_username(username)
      tvr_periods_reviewers
    else
      raise tvr_periods_reviewers.errors.full_messages.first.to_s
    end
  end

  def save_with_username(username)
    self.created_by = self.updated_by = username
    #set_defaults
    save
  end
end
