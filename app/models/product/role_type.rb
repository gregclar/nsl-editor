# frozen_string_literal: true

class Product::RoleType < ActiveRecord::Base
  strip_attributes
  self.table_name = "product_role_type"
  self.primary_key = "id"
  self.sequence_name = "nsl_global_seq"
  has_many :user_product_roles, class_name: "User::ProductRole", foreign_key: "product_role_type_id"
end
