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

#  A taxonomy-element-comment
class TaxonomyElementComment < ActiveRecord::Base
  strip_attributes
  self.table_name = "taxonomy_element_comment"
  self.primary_key = "id"
  belongs_to :tree_element
  belongs_to :taxonomy_review_period
  validates :comment, presence: true

  # The table isn't in all schemas, so check it's there
  def self.exists?
    begin 
      TaxonomyElementComment.all.count
    end
    true
  rescue => e
    false
  end

  def self.create(params, username)
    telc = TaxonomyElementComment.new(params)
    if telc.save_with_username(username)
      telc
    else
      raise telc.errors.full_messages.first.to_s
    end
  end

  def save_with_username(username)
    self.created_by = self.updated_by = username
    save
  end

  def self.comments_per_tree_element(tree_element_id)
    TaxonomyElementComment.where(tree_element_id: tree_element_id).order(:created_at)
  end
end
