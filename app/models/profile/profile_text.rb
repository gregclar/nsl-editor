# app/models/profile/profile_text.rb
module Profile
  class ProfileText < ApplicationRecord
    strip_attributes
    self.table_name = "temp_profile.profile_text"
    # Assuming `id` is the primary key by default
    # self.primary_key = "id"
    # self.sequence_name = "nsl_global_seq"

    has_many :profile_items, class_name: 'Profile::ProfileItem', foreign_key: 'profile_text_id'
    validates :value_html, presence: true
    validates :value, presence: true
  end
end
