# app/models/profile/profile_product.rb
module Profile
  class ProfileProduct < ApplicationRecord
    self.table_name = "temp_profile.profile_product"
    belongs_to :product, class_name: 'Profile::Product', foreign_key: 'product_id'
    belongs_to :profile_item_type, class_name: 'Profile::ProfileItemType', foreign_key: 'profile_item_type_id'
    validates :product_id, presence: true
    validates :profile_item_type_id, presence: true
  end
end
  