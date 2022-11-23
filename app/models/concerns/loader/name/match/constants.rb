#   Copyright 2022 Australian National Botanic Gardens
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
# Loader Name entity
module Loader::Name::Match::Constants

  CREATED = [1,0,0]
  DECLINED = [0,1,0]
  ERROR = [0,0,1]
  DECLINED_INSTANCE = "<span class='firebrick'>Declined to make instance</span>"
  CREATED_INSTANCE = "<span class='darkgreen'>Made instance</span>"
  ERROR_INSTANCE = "<span class='red'>Failed to make instance</span>"
  DECLINED_MATCH = "<span class='firebrick'>Declined to make match</span>"
  CREATED_MATCH = "<span class='darkgreen'>Made match</span>"
  ERROR_MATCH = "<span class='red'>Failed to make match</span>"
end

