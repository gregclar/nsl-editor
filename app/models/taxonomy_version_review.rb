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
class TaxonomyVersionReview < ActiveRecord::Base
  strip_attributes
  self.table_name = "taxonomy_version_review"
  self.primary_key = "id"
  #self.sequence_name = "nsl_global_seq"
  belongs_to :tree_version
  validates :name, presence: true
  has_many :taxonomy_version_review_periods
 
  # The table isn't in all schemas, so check it's there
  def self.exists?
    begin 
      TaxonomyVersionReview.all.count
    end
    true
  rescue => e
    false
  end

  def fresh?
    false
  end

  def has_parent?
    false
  end

  def record_type
    'TaxonomyVersionReview'
  end

  def self.create(params, username)
    taxonomy_version_review = TaxonomyVersionReview.new(params)
    if taxonomy_version_review.save_with_username(username)
      taxonomy_version_review
    else
      raise taxonomy_version_review.errors.full_messages.first.to_s
    end
  end

  def save_with_username(username)
    self.created_by = self.updated_by = username
    #set_defaults
    save
  end

  def update_if_changed(params, username)
    assign_attributes(params)
    if changed?
      self.updated_by = username
      save!
      "Updated"
    else
      "No change"
    end
  end

  def can_be_deleted?
    taxonomy_version_review_periods.size.zero?
  end

  def active?
    taxonomy_version_review_periods.each do |review_period|
      return true if review_period.active?
    end
    return false
  end
end
