# app/models/profile/product.rb
module Profile
  class Product < ApplicationRecord
    self.table_name = "temp_profile.product"
    has_many :profile_products, class_name: 'Profile::ProfileProduct', foreign_key: 'product_id'
    validates :name, presence: true
  end
end
  