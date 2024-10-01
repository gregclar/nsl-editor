# app/models/profile/profile_annotation.rb
# == Schema Information
#
# Table name: profile_annotation(An annotation made on a profile.)
#
#  id(A system wide unique identifier allocated to each profile annotation record.)                   :bigint           not null, primary key
#  api_date(The date when a system user, script, jira or services task last changed this record.)     :timestamptz
#  api_name(The name of a system user, script, jira or services task which last changed this record.) :string(50)
#  created_by(The user id of the person who created this data)                                        :string(50)       not null
#  lock_version(A system field to manage row level locking.)                                          :integer          default(0), not null
#  source_id_string(The identifier from the source system that this profile text was imported from.)  :string(100)
#  source_system(The source system that this profile text was imported from.)                         :text
#  updated_by(The user id of the person who last updated this data)                                   :string(50)       not null
#  value(The annotation statement.)                                                                   :text             not null
#  created_at(The date and time this data was created.)                                               :timestamptz      not null
#  updated_at(The date and time this data was updated.)                                               :timestamptz      not null
#  profile_item_id(The profile item about which this annotation is made.)                             :bigint           not null
#  source_id(The key at the source system imported on migration)                                      :bigint
#
# Indexes
#
#  profile_annotation_item_i  (profile_item_id)
#
# Foreign Keys
#
#  profile_annotation_profile_item_id_fkey  (profile_item_id => profile_item.id)
#
module Profile
    class ProfileAnnotation < ApplicationRecord
      self.table_name = "profile_annotation"
      # Assuming `id` is the primary key by default
      # self.primary_key = "id"
      # self.sequence_name = "nsl_global_seq"
  
      belongs_to :profile_item, class_name: 'Profile::ProfileItem', foreign_key: 'profile_item_id'
      
      validates :value, presence: true
    end
  end
  
