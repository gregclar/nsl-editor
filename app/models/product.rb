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
class Product < ApplicationRecord
  strip_attributes
  self.table_name = "product"
  self.primary_key = "id"
  self.sequence_name = "nsl_global_seq"

  belongs_to :tree, optional: true
  belongs_to :reference, optional: true
  has_many :user_product_roles, class_name: "User::ProductRole", foreign_key: "product_id"
end
