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
# Loader Name entity
class Org::Batch::ReviewVoter < ActiveRecord::Base
  strip_attributes
  self.table_name = "org_batch_review_voter"
  self.primary_key = [:org_id, :batch_review_id]

  belongs_to :org

  belongs_to :batch_review,
             class_name: "Loader::Batch::Review",
             foreign_key: "batch_review_id"

  has_many :name_review_comments, class_name: "Loader::Name::Review::Comment", foreign_key: "org_batch_review_id"
  has_many :loader_name_review_votes, class_name: "Loader::Name::Review::Vote", query_constraints: [:org_id, :batch_review_id]
  alias_attribute :name_review_votes, :loader_name_review_votes

  validates :org_id, uniqueness: { scope: :batch_review_id,
    message: "cannot be registered twice for the same batch review" }

  def self.create(params, username)
    obrv = Org::Batch::ReviewVoter.new(params)
    obrv.save_with_username(username)

    obrv
  end

  def set_defaults
  end

  def save_with_username(username)
    self.created_by = self.updated_by = username
    save!
  end
end
