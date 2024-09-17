# app/models/profile/profile_annotation.rb
module Profile
    class ProfileAnnotation < ApplicationRecord
      self.table_name = "temp_profile.profile_annotation"
      # Assuming `id` is the primary key by default
      # self.primary_key = "id"
      # self.sequence_name = "nsl_global_seq"
  
      belongs_to :profile_item, class_name: 'Profile::ProfileItem', foreign_key: 'profile_item_id'
      
      validates :value, presence: true
    end
  end
  