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

# Record a preferred matching name for a raw loader name record.
class Loader::Name::AsNameMatcher
  def initialize(loader_name, authorising_user)
    debug("Loader::Name::AsNameMatcher for loader::name: #{loader_name.simple_name} (#{loader_name.record_type})")
    @loader_name = loader_name
    @authorising_user = authorising_user
    @log_tag = " for #{@loader_name.id}, batch: #{@loader_name.batch.name} , seq: #{@loader_name.seq} #{@loader_name.simple_name} (#{@loader_name.true_record_type})"
  end

  def find_or_create_preferred_match
    return already_exists if preferred_match?
    return no_further_processing if @loader_name.no_further_processing?
    return misapp if @loader_name.misapplied?

    if make_preferred_match?
      return 1
    else
      return 0
    end
  rescue => e
    Rails.logger.error(e.to_s)
    log_to_table("Error: finding or creating preferred match for batch - #{e.to_s}")
    return 0
  end

  def stop(msg)
    puts "Stopping because: #{msg}"
  end

  def preferred_match?
    return !@loader_name.preferred_matches.empty?
  end

  def already_exists
    log_to_table("<span class='firebrick'>Declined to make preferred match</span> - existing")
    [0,1,0]
  end

  def misapp
    log_to_table("<span class='firebrick'>Declined to make preferred match</span> - misapps not eligible")
    [0,1,0]
  end

  def no_further_processing
    log_to_table("<span class='firebrick'>Declined to make preferred match</span> - no further processing")
    [0,1,0]
  end

  def make_preferred_match?
    if exactly_one_matching_name? &&
         matching_name_has_primary? &&
         matching_name_has_exactly_one_primary?
      create_match
      log_to_table("<span class='darkgreen'>Made preferred match</span>")
      [1,0,0]
    else
      log_to_table("<span class='firebrick'>Declined to make a preferred match</span> no single match found")
      [0,1,0]
    end
  end

  def create_match
    pref = @loader_name.loader_name_matches.new
    pref.name_id = @loader_name.matches.first.id
    pref.instance_id = @loader_name.matches.first.primary_instances.first.id
    pref.relationship_instance_type_id = @loader_name.riti
    pref.created_by = pref.updated_by = "#{@authorising_user}"
    pref.save!
  end

  def log_to_table(entry)
    BulkProcessingLog.log("#{entry} #{@log_tag}", @authorising_user)
  rescue => e
    Rails.logger.error("Couldn't log to table: #{e.to_s}")
  end

  def exactly_one_matching_name?
    @loader_name.matches.size == 1
  end

  def matching_name_has_primary?
    !@loader_name.name_match_no_primary?
  end

  def matching_name_has_exactly_one_primary?
    @loader_name.matches.first.primary_instances.size == 1
  end

  def relationship_instance_type_id
    return nil if @loader_name.accepted?
    return @loader_name.riti
  end

  def simple_name
    @loader_name.simple_name
  end

  def debug(msg)
    Rails.logger.debug("#{msg}")
  end
end
