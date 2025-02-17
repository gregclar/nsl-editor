# frozen_string_literal: true

#   Copyright 2019 Australian National Botanic Gardens
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
# == Schema Information
#
# Table name: product(Describes a product available within the NSL infrastructure.)
#
#  id(A system wide unique identifier allocated to each profile product.)                            :bigint           not null, primary key
#  api_date(The date when a script, jira or services task last changed this record.)                 :timestamptz
#  api_name(The name of a script, jira or services task which last changed this record.)             :string(50)
#  created_by(The user id of the person who created this data)                                       :string(50)       not null
#  description_html(The full name for this profile product. i.e. Flora of Australia.)                :text
#  internal_notes(Team notes about the management or maintenance of this product.)                   :text
#  is_available(Indicates this product is publicly available.)                                       :boolean          default(FALSE), not null
#  is_current(Indicates this product is currently being maintained and published.)                   :boolean          default(FALSE), not null
#  is_name_index                                                                                     :boolean          default(FALSE), not null
#  lock_version(A system field to manage row level locking.)                                         :integer          default(0), not null
#  name(The standard acronym for this profile product. i.e. FOA, APC.)                               :text             not null
#  source_id_string(The identifier from the source system that this profile text was imported from.) :string(100)
#  source_system(The source system that this profile text was imported from.)                        :string(50)
#  updated_by(The user id of the person who last updated this data)                                  :string(50)       not null
#  created_at(The date and time this data was created.)                                              :timestamptz      not null
#  updated_at(The date and time this data was updated.)                                              :timestamptz      not null
#  namespace_id(The auNSL dataset that physically contains this profile text.)                       :bigint
#  reference_id(The highest level reference for this product.)                                       :bigint
#  source_id(The key at the source system imported on migration.)                                    :bigint
#  tree_id(The tree (taxonomy) used for this product.)                                               :bigint
#
# Foreign Keys
#
#  product_reference_id_fkey  (reference_id => reference.id)
#  product_tree_id_fkey       (tree_id => tree.id)
#
class Product < ApplicationRecord
  strip_attributes
  self.table_name = "product"
  self.primary_key = "id"
  self.sequence_name = "nsl_global_seq"

  belongs_to :tree, optional: true
  belongs_to :reference, optional: true
  has_many :user_product_roles, class_name: "User::ProductRole", foreign_key: "product_id"
end
