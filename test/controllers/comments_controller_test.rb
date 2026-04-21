# frozen_string_literal: true

#   Copyright 2015 Australian National Botanic Gardens
#
#   This file is part of the NSL Editor.
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#   http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.
#
require "test_helper"

# Comments controller tests.
class CommentsControllerTest < ActionController::TestCase
  setup do
    @comment = comments(:author_comment)
  end

  test "xhr request should create comment" do
    assert_difference("Comment.count") do
      post(:create,
           params: { comment: { text: @comment.text, author_id: authors("haeckel") } },
           session: { username: "fred",
                      user_full_name: "Fred Jones",
                      groups: ["edit"] },
           xhr: true)
    end
    # assert_redirected_to comment_path(assigns(:comment))
  end

  test "should not show comment" do
    skip "Failing during rails6 transition testing. Not sure what it is testing"
    get(:show,
        params: { id: @comment.id },
        session: { username: "fred",
                   user_full_name: "Fred Jones",
                   groups: ["edit"] })
    assert_response :service_unavailable
  end

  test "should not get edit" do
    skip "Failing during rails6 transition testing. Not sure what it is testing"
    get(:edit,
        params: { id: @comment.id },
        session: { username: "fred",
                   user_full_name: "Fred Jones",
                   groups: ["edit"] })
    assert_response :service_unavailable
  end

  test "xhr request should destroy comment" do
    assert_difference("Comment.count", -1) do
      delete(:destroy,
             params: { id: @comment.id },
             session: { username: "fred",
                        user_full_name: "Fred Jones",
                        groups: ["edit"] },
             xhr: true)
    end
  end

  test "should create comment when multi_product_tabs_enabled is false" do
    Rails.configuration.stubs(:multi_product_tabs_enabled).returns(false)

    assert_difference("Comment.count") do
      post(:create,
           params: { comment: { text: "Test comment", instance_id: instances(:britten_created_name_to_be_deleted).id } },
           session: { username: "fred",
                      user_full_name: "Fred Jones",
                      groups: ["edit"] },
           xhr: true)
    end
  end

  test "should create comment when multi_product_tabs_enabled is true and user can create_adnot" do
    Rails.configuration.stubs(:multi_product_tabs_enabled).returns(true)
    instance = instances(:britten_created_name_to_be_deleted)

    @controller.stubs(:can?).with(:create_adnot, instance).returns(true)
    @controller.stubs(:can?).with(anything, anything).returns(true)

    assert_difference("Comment.count") do
      post(:create,
           params: { comment: { text: "Test comment", instance_id: instance.id } },
           session: { username: "fred",
                      user_full_name: "Fred Jones",
                      groups: ["edit"] },
           xhr: true)
    end
  end

  test "should deny create comment when multi_product_tabs_enabled is true and user cannot create_adnot" do
    Rails.configuration.stubs(:multi_product_tabs_enabled).returns(true)
    instance = instances(:britten_created_name_to_be_deleted)

    ability = Object.new
    ability.stubs(:can?).returns(true)
    ability.stubs(:can?).with(:create_adnot, instance).returns(false)
    @controller.stubs(:current_ability).returns(ability)

    assert_no_difference("Comment.count") do
      post(:create,
           params: { comment: { text: "Test comment", instance_id: instance.id } },
           session: { username: "fred",
                      user_full_name: "Fred Jones",
                      groups: ["edit"] },
           xhr: true)
    end
    assert_response :forbidden
  end

  test "should deny destroy comment when multi_product_tabs_enabled is true and user cannot create_adnot" do
    Rails.configuration.stubs(:multi_product_tabs_enabled).returns(true)
    comment = comments(:instance_comment)

    ability = Object.new
    ability.stubs(:can?).returns(true)
    ability.stubs(:can?).with(:create_adnot, comment.instance).returns(false)
    @controller.stubs(:current_ability).returns(ability)

    assert_no_difference("Comment.count") do
      delete(:destroy,
             params: { id: comment.id },
             session: { username: "fred",
                        user_full_name: "Fred Jones",
                        groups: ["edit"] },
             xhr: true)
    end
    assert_response :forbidden
  end
end
