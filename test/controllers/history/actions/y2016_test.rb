# frozen_string_literal: true

#
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
class HistoryActionsY2016Test < ActionController::TestCase
  tests HistoryController
  # setup do
  # @comment = comments(:author_comment)
  # end

  test "history actions for 2016 page" do
    get("for_year",
        params: { "year" => "2016" },
        session: { username: "fred",
                   user_full_name: "Fred Jones",
                   groups: [] },
        xhr: true)
    assert_response :success
    assert_select "h3",
                  /\bChanges 2016\b/,
                  "Should find heading for Changes 2016"
    assert_select "body", /\b24-Oct-2016/,
                  "Should find 24-Oct-2016 a"
    assert_select "body", /24-Oct.2016/
    assert_select "body", /NSL-478/
    "Should find NSL-478"
  end
end
