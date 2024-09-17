# app/models/profile/profile_object_type.rb
module Profile
  class ProfileObjectType < ApplicationRecord
    self.table_name = "temp_profile.profile_object_type"
    has_many :profile_item_types, class_name: 'Profile::ProfileItemType', foreign_key: 'profile_object_type_id'
    validates :name, presence: true
  end
end
