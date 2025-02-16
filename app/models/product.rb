class Product < ApplicationRecord
  strip_attributes
  self.table_name = "product"
  self.primary_key = "id"
  self.sequence_name = "nsl_global_seq"

  belongs_to :tree, optional: true
  belongs_to :reference, optional: true
  has_many :user_product_roles, class_name: "User::ProductRole", foreign_key: "product_id"

end
