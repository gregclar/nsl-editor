# == Schema Information
#
# Table name: profile_item(The use of a statement/content for a taxon concept by a product. The specific statement/content is recorded based on its explicit data type (text, reference, distribution etc).)
#
#  id(A system wide unique identifier allocated to each profile item record.)                                                                                                                                                                                :bigint           not null, primary key
#  api_date(The date when a system user, script, jira or services task last changed this record.)                                                                                                                                                            :timestamptz
#  api_name(The name of a system user, script, jira or services task which last changed this record.)                                                                                                                                                        :string(50)
#  created_by(The user id of the person who created this data)                                                                                                                                                                                               :string(50)       not null
#  end_date(The date when this version of the content was replaced or ended. Used to manage versions of content within the same taxon concept.)                                                                                                              :timestamptz
#  is_draft(A boolean to indicate this profile item is in draft mode and is not publicly available.)                                                                                                                                                         :boolean          default(TRUE), not null
#  is_object_type_reference(A placeholder to indicate this profile item is for a list of references available in profile_references. 1=is a profile_reference data, null = not a profile reference. Used to constrain an item type to only one object type.) :boolean          default(FALSE), not null
#  lock_version(A system field to manage row level locking.)                                                                                                                                                                                                 :integer          default(0), not null
#  published_date(The date this version of the content was published. Used to manage versions of content within the same taxon concept.)                                                                                                                     :timestamptz
#  source_id_string(The identifier from the source system that this profile text was imported from.)                                                                                                                                                         :string(100)
#  source_system(The source system that this profile text was imported from.)                                                                                                                                                                                :string(50)
#  statement_type(Indicates whether this statement/content is original content (fact) or re-use (link) of original content.)                                                                                                                                 :text             default("fact"), not null
#  updated_by(The user id of the person who last updated this data)                                                                                                                                                                                          :text             not null
#  created_at(The date and time this data was created.)                                                                                                                                                                                                      :timestamptz      not null
#  updated_at(The date and time this data was updated.)                                                                                                                                                                                                      :timestamptz      not null
#  instance_id(The taxon concept (as the accepted taxon name usage instance) for which this statement/content is being made.)                                                                                                                                :bigint           not null
#  namespace_id(The auNSL dataset that physically contains this profile text.)                                                                                                                                                                               :bigint
#  product_item_config_id(The category of statement/content for this profile item (as the profile item type).)                                                                                                                                               :bigint           not null
#  profile_object_rdf_id(The data object which contains the statement/content for this profile item.)                                                                                                                                                        :text             not null
#  profile_text_id(The profile text for this profile item.)                                                                                                                                                                                                  :bigint
#  source_id(The key at the source system imported on migration)                                                                                                                                                                                             :bigint
#  source_profile_item_id(The statement/content (as profile item) being re-used for this profile.)                                                                                                                                                           :bigint
#  tree_element_id                                                                                                                                                                                                                                           :bigint
#
# Indexes
#
#  pi_instance_i         (instance_id)
#  pi_text__id_i         (profile_text_id)
#  pi_tree_element_id_i  (tree_element_id)
#
# Foreign Keys
#
#  profile_item_instance_id_fkey             (instance_id => instance.id)
#  profile_item_product_item_config_id_fkey  (product_item_config_id => product_item_config.id)
#  profile_item_profile_object_rdf_id_fkey   (profile_object_rdf_id => profile_object_type.rdf_id)
#  profile_item_profile_text_id_fkey         (profile_text_id => profile_text.id)
#  profile_item_source_profile_item_id_fkey  (source_profile_item_id => profile_item.id)
#  profile_item_tree_element_id_fkey         (tree_element_id => tree_element.id)
#
FactoryBot.define do
  factory :profile_item, class: "Profile::ProfileItem" do
    instance_id { 1 }
    product_item_config_id { 1 }
    profile_object_rdf_id { "Sample Profile object rdf" }
    is_draft { true }
    published_date { Time.current }
    end_date { Time.current }
    statement_type { "fact" }
    is_object_type_reference { false }
    source_id_string { "Sample Source id string" }
    source_system { "Sample Source system" }
    lock_version { 1 }
    updated_by { "Sample Updated by" }
    created_by { "Sample Created by" }
    api_name { "Sample Api name" }
    api_date { Time.current }

    association :instance
    association :product_item_config
    association :profile_text
  end
end
