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


#  We need to place Orchids on a draft tree.
class Loader::Batch::Stats::Reporter
  def initialize(name_string, batch_id, work_on_accepted)
    @name_string = name_string.downcase.gsub(/\*/,'%')
    @batch_id = batch_id
    @work_on_accepted = work_on_accepted
    @work_on_excluded = !work_on_accepted
    report
  end

  def report
    if @work_on_accepted
      Loader::Batch::Stats::ForAcceptedNames
        .new(@name_string, @batch_id).report
    else
      Loader::Batch::Stats::Reporter::ForExcludedNames
        .new(@name_string, @batch_id).report
    end
  end
end