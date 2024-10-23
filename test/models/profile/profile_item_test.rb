# # frozen_string_literal: true

# #   Copyright 2015 Australian National Botanic Gardens
# #
# #   This file is part of the NSL Editor.
# #
# #   Licensed under the Apache License, Version 2.0 (the "License");
# #   you may not use this file except in compliance with the License.
# #   You may obtain a copy of the License at
# #
# #   http://www.apache.org/licenses/LICENSE-2.0
# #
# #   Unless required by applicable law or agreed to in writing, software
# #   distributed under the License is distributed on an "AS IS" BASIS,
# #   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# #   See the License for the specific language governing permissions and
# #   limitations under the License.
# #
# require "test_helper"

# class Profile::ProfileItemTest < ActiveSupport::TestCase
#   # def setup
#   #   @product_item_config = product_item_config(:ecology_pic)
#   #   @profile_object_type = profile_object_type(:profile_text)
#   # end

#   test 'belongs to product item config' do
#     attrs = {
#       instance_id: 1,
#       profile_object_rdf_id: "text",
#       created_by: "tester",
#       created_at: Time.now,
#       updated_by: "tester",
#       updated_at: Time.now,
#       product_item_config_id: 1,
#       profile_text_id: 1,
#       statement_type: "fact"
#     }
#     profile_item = Profile::ProfileItem.new(attrs)
#     debugger
#     #assert_equal @product_item_config.id, profile_item.product_item_config_id
#   end

#   # test 'belongs to profile text' do
#   #   profile_text = create(:profile_text)
#   #   profile_item = build(:profile_item, :ecology_pit, is_object_type_reference: false, profile_text_id: profile_text.id, profile_object_rdf_id: "text")
#   #   assert_equal profile_text.id, profile_item.profile_text_id
#   # end

#   # test 'belongs to profile object type (optional)' do
#   #   profile_item = buiald(:profile_item, profile_object_rdf_id: @profile_object_type.rdf_id)
#   #   assert_nil profile_item.profile_object_type
#   # ensure
#   #   Profile::ProfileObjectType.destroy_all
#   # end

#   # test 'has many profile item references' do
#   #   reference1 = create(:profile_item_reference, profile_item_id: build(:profile_item).id)
#   #   reference2 = create(:profile_item_reference, profile_item_id: build(:profile_item).id)

#   #   profile_item = ProfileItem.find(reference1.profile_item_id)
#   #   assert_equal [reference1, reference2].map(&:id), profile_item.profile_item_references.map(&:id)
#   # end

#   # test 'has one product through product item config' do
#   #   profile_item = create(:profile_item)
#   #   product = build(:product)

#   #   # Create a product item config to associate with the profile item
#   #   product_item_config = create(:product_item_config, product_id: product.id)
#   #   profile_item.product_item_config = product_item_config

#   #   assert_equal product.id, profile_item.product_id
#   # end

#   # test 'has one profile item type through profile object type' do
#   #   profile_item = build(:profile_item, profile_object_rdf_id: @profile_object_type.rdf_id)

#   #   assert_nil profile_item.profile_item_type
#   # ensure
#   #   Profile::ProfileItemType.destroy_all
#   # end

#   # test 'has one profile item annotation' do
#   #   annotation = create(:profile_item_annotation)
#   #   profile_item = build(:profile_item, id: annotation.profile_item_id)

#   #   assert_equal annotation.id, profile_item.profile_item_annotations.first.id
#   # end

#   # test 'validates presence of statement type' do
#   #   profile_item = build(:profile_item, statement_type: nil)

#   #   refute_validity_of(profile_item)
#   # end

# private

#   def create(record_class, attributes = {})
#     record_class.create(attributes)
#   rescue ActiveRecord::RecordInvalid => e
#     raise Minitest::Assertion, e.message
#   end

#   def build(record_class, attributes = {})
#     record_class.new(attributes)
#   rescue NoMethodError => e
#     raise Minitest::Assertion, "Cannot instantiate #{record_class}"
#   end

#   def refute_validity_of(profile_item)
#     refute profile_item.valid?, 'profile item should be invalid without statement type'
#   end
# end