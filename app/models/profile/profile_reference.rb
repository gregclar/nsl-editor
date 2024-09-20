# app/models/profile/profile_reference.rb
module Profile
    class ProfileReference < ApplicationRecord
      self.table_name = "temp_profile.profile_reference"
      self.locking_column = nil
      # Assuming `id` is the primary key by default
      # self.primary_key = "id"
      # self.sequence_name = "nsl_global_seq"
  
      belongs_to :profile_item, class_name: 'Profile::ProfileItem', foreign_key: 'profile_item_id'
      
      validates :profile_item_id, presence: true
      validates :reference_id, presence: true
    end
  end
  