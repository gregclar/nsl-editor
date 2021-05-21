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

#  A taxonomy review period comment on a tree version element by
#  a taxonomy reviewer
class TvrPeriodTveComment < ActiveRecord::Base
  strip_attributes
  self.table_name = "tvr_period_tve_comment"
  self.primary_key = "id"
  belongs_to :tree_version_element
  belongs_to :taxonomy_version_review_period
  belongs_to :taxonomy_reviewer
  validates :comment, presence: true

  # The table isn't in all schemas, so check it's there
  def self.exists?
    begin 
      TvrPeriodTveComment.first
    end
    true
  rescue => e
    false
  end

  def self.xcreate(params, username)
    comment = TvrPeriodTveComment.new(params)
    if comment.save_with_username(username)
      comment
    else
      raise comment.errors.full_messages.first.to_s
    end
  end

  def save_with_username(username)
    self.created_by = self.updated_by = username
    save
  end

  def self.comments_per_tree_element(tree_element_id)
    TvrPeriodTveComment.where(tree_element_id: tree_element_id).order(:created_at)
  end
end
