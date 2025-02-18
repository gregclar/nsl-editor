# frozen_string_literal: true

class User::ProductRole < ActiveRecord::Base
  strip_attributes
  self.table_name = "user_product_role"
  self.primary_key = [:user_id, :product_id, :product_role_type_id]
  belongs_to :user
  belongs_to :product
  belongs_to :role_type, class_name: "Product::RoleType", foreign_key: "product_role_type_id"
end

