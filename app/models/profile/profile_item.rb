# app/models/profile/profile_item.rb
module Profile
    class ProfileItem < ApplicationRecord
      self.table_name = "temp_profile.profile_item"
      # Assuming `id` is the primary key by default
      # self.primary_key = "id"
      # self.sequence_name = "nsl_global_seq"
  
      belongs_to :product, class_name: 'Profile::Product', foreign_key: 'product_id'
      belongs_to :profile_item_type, class_name: 'Profile::ProfileItemType', foreign_key: 'profile_item_type_id'
      belongs_to :profile_object_type, class_name: 'Profile::ProfileObjectType', foreign_key: 'profile_object_type_id'
      belongs_to :profile_text, class_name: 'Profile::ProfileText', foreign_key: 'profile_text_id', optional: true
      belongs_to :instance, class_name: 'Instance', foreign_key: 'instance_id'  # Add this line
  
      has_many :profile_annotations, class_name: 'Profile::ProfileAnnotation', foreign_key: 'profile_item_id'
      has_many :profile_references, class_name: 'Profile::ProfileReference', foreign_key: 'profile_item_id'
  
      validates :statement_type, presence: true
    end
  end
  