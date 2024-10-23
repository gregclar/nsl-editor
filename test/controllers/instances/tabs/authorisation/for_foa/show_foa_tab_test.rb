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

# Single controller test.
class InstanceForFoaShowMostTabsTest < ActionController::TestCase
  tests InstancesController
  setup do
    Rails.configuration.foa_profile_aware = true
    @instance = instances(:gaertner_created_metrosideros_costata)
    @product_item_config = product_item_config(:ecology_pic)
    @profile_item = profile_item(:ecology_pi)
    @request.headers["Accept"] = "application/javascript"
  end

  test "should show detail and FOA tab links if foa editor requests details tab" do
    get(:show,
        params: { id: @instance.id,
                  tab: "tab_foa_profile" },
        session: { username: "fred",
                   user_full_name: "Fred Jones",
                   groups: ["edit","foa"] })
    
    assert_select "a#instance-foa-profile-tab",
                   /FOA/
                   "Should not show 'FOA Profile' tab link"
     assert_select "h4", 
                   @product_item_config.display_html,
                   "Should show the product item config display_html"
  end

end
