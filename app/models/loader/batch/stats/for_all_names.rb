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

# Batch Statistics report
# Returns a hash
class Loader::Batch::Stats::ForAllNames
  def initialize(name_string, batch_id)
    @name_string = name_string.downcase.gsub(/\*/, "%")
    @batch_id = batch_id
    @report = {}
  end

  def report
    beginning
    middle
    end_part
    @report
  end

  def beginning
    @report[:search] = search
    @report[:lock] = { status: lock_status }
    @report[:record_types] = record_types
    @report[:no_further_processing] = NoFurtherProcessing.new(core_search)
                                                         .report
  end

  def middle
    @report[:matched] = Matched.new(core_search).report
    @report[:unmatched] = Unmatched.new(core_search).report
  end

  def end_part
    @report[:matched_with_decision] = MatchedWithDecision.new(core_search)
                                                         .report
    @report[:instances] = Instances.new(core_search).report
    @report[:instances_breakdown] = InstancesBreakdown.new(core_search).report
  end

  def search
    { string: @name_string,
      reported: Time.now.strftime("%d-%b-%Y %H:%M:%S"),
      category: "Accepted" }
  end

  def record_types
    { accepted: accepteds,
      excluded: excludeds,
      synonym: synonyms,
      misapplied: misapplieds,
      hybrid_cross: hybrid_crosses,
      total: names_and_synonyms_count }
  end

  def core_search
    if @name_string.match(/\Afamily:/i)
      family_string = @name_string.sub(/\Afamily: */i,'')
      Loader::Name.family_string_search(family_string)
                  .joins(:loader_batch)
                  .where(loader_batch: { id: @batch_id })
                  .where("record_type != 'heading'")
    else
      Loader::Name.name_string_search(@name_string)
                  .joins(:loader_batch)
                  .where(loader_batch: { id: @batch_id })
                  .where("record_type != 'heading'")
    end
  end

  def names_and_synonyms_count
    core_search.count
  end

  def lock_status
    Loader::Batch::JobLock.locked? ? "Locked" : "Unlocked"
  end

  def accepteds
    core_search.where("record_type = 'accepted'").count
  end

  def excludeds
    core_search.where("record_type = 'excluded'").count
  end

  def synonyms
    core_search.where("record_type = 'synonym'").count
  end

  def misapplieds
    core_search.where("record_type = 'misapplied'").count
  end

  def hybrid_crosses
    core_search.where("record_type = 'hybrid_cross'").count
  end
end
