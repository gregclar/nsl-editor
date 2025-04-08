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
# == Schema Information
#
# Table name: user_product_role
#
#  created_by           :string(50)       not null
#  lock_version         :bigint           default(0), not null
#  updated_by           :string(50)       not null
#  created_at           :timestamptz      not null
#  updated_at           :timestamptz      not null
#  product_id           :bigint           not null, primary key
#  role_id              :bigint           not null, primary key
#  user_id              :bigint           not null, primary key
#
# Foreign Keys
#
#  upr_product_fk            (product_id => product.id)
#  upr_role_fk               (role_id => role.id)
#  upr_users_fk              (user_id => users.id)
#
class User::ProductRole < ActiveRecord::Base
  strip_attributes
  self.table_name = "user_product_role"
  self.primary_key = %i[user_id product_id role_id]
  belongs_to :user
  belongs_to :product
  belongs_to :role
  validates :user_id, :role_id, :product_id, presence: true
  validates :user_id, uniqueness: { scope: [:role_id, :product_id],
    message: "cannot have the same role twice for the same product" }

  def self.create(params, username)
    upr = User::ProductRole.new(params)
    raise upr.errors.full_messages.first.to_s unless upr.save_with_username(username)

    upr
  end

  def save_with_username(username)
    self.created_by = self.updated_by = username
    save
  end

  def display_text
    "#{product.name} #{role.name} role for #{user.user_name}"
  end

  def available_roles
    Role.all - user.roles
  end

  def all_product_role_combinations
    Enumerator.product(Product.all.map{|p| p.name}, Role.all.map{|r| r.name}).to_a
  end

  def user_current_product_role_combinations
    user.product_roles.map {|upr| [upr.product.name,upr.role.name]}
  end

  def user_available_product_role_combinations
    all_product_role_combinations - user_current_product_role_combinations
  end

  def user_available_prc_for_product
    user_available_product_role_combinations.select {|item| item.first == product.name}
  end

  def role_names_available
    user_available_prc_for_product.map {|pr| pr.last}
  end

  def roles_available
    role_names = role_names_available
    all_roles = Role.all.where('not deprecated').order('name')
    all_roles.select {|role| role_names.include?(role.name) }
  end
end
