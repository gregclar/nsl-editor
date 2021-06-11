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

#  A taxonomy-review
class TaxonomyReviewer < ActiveRecord::Base
  strip_attributes
  self.table_name = "taxonomy_reviewer"
  self.primary_key = "id"
  has_many :periods_reviewers, class_name: "TvrPeriodsReviewers", foreign_key: "taxonomy_reviewer_id"
  has_many :periods, through: :periods_reviewers
 
  validates :username, presence: true, uniqueness: true
  validates :organisation_name, presence: true

  def display_as
    'TaxonomyReviewer'
  end

  def self.create(params, username)
    taxonomy_reviewer = TaxonomyReviewer.new(params)
    if taxonomy_reviewer.save_with_username(username)
      taxonomy_reviewer
    else
      raise taxonomy_reviewer.errors.full_messages.first.to_s
    end
  end

  def save_with_username(username)
    self.created_by = self.updated_by = username
    #set_defaults
    save
  end

  def self.available_reviewers
    self.all.sort {|x,y| x.username <=> y.username}
  end

  def reviewer_in_period(period_id)
    TvrPeriodsReviewers.where(taxonomy_reviewer_id: self, tvr_period_id: period_id)&.first
  end
end
