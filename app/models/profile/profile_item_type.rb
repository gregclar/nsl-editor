# app/models/profile/profile_item_type.rb
module Profile
  class ProfileItemType < ApplicationRecord
    self.table_name = "temp_profile.profile_item_type"
    belongs_to :profile_object_type, class_name: 'Profile::ProfileObjectType', foreign_key: 'profile_object_type_id'
    has_many :profile_products, class_name: 'Profile::ProfileProduct', foreign_key: 'profile_item_type_id'
    validates :name, presence: true
  end
end
  