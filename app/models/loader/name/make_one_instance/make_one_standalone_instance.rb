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
class Loader::Name::MakeOneInstance::MakeOneStandaloneInstance
  def initialize(loader_name, user, job)
    @tag = "#{self.class} for #{loader_name.simple_name} (#{loader_name.record_type})"
    @loader_name = loader_name
    @user = user
    @job = job
    @match = loader_name.preferred_match
  end

  def create
    return using_existing_instance if using_existing_instance?
    return stand_already_noted if standalone_instance_already_noted?
    return stand_already_for_default_ref if standalone_instance_for_default_ref?

    case
    when @match.instance_choice_confirmed == false
      @match.use_batch_default_reference = true
      @match.instance_choice_confirmed = true
      @match.save!
      return create_using_default_ref
    when @match.use_batch_default_reference == true
      return create_using_default_ref
    when @match.copy_append_from_existing_use_batch_def_ref == true
      return copy_and_append
    else
      return unknown_option
    end
  end

  def create_using_default_ref 
    UseDefaultRef.new(@loader_name, @user, @job).create
  end

  def copy_and_append 
    CopyAndAppend.new(@loader_name, @user, @job).create
  end

  def using_existing_instance?
    @match.use_existing_instance == true 
  end

  def using_existing_instance
    log("#{Constants::DECLINED_INSTANCE} - using existing " +
                 " instance for #{@loader_name.simple_name} #{@loader_name.id}")
    return Constants::DECLINED
  end

  def stand_already_noted
    log("#{Constants::DECLINED_INSTANCE} - standalone instance " +
                 "already noted for #{@loader_name.simple_name} " +
                 "#{@loader_name.id}")
    Constants::DECLINED
  end

  def find_standalone_instances_for_default_ref
    Instance.where(name_id: @match.name_id)
             .where(reference_id:
                    @loader_name.loader_batch.default_reference.id)
             .joins(:instance_type)
             .where(instance_type: { standalone: true})
  end

  def standalone_instance_for_default_ref?
    instances =  find_standalone_instances_for_default_ref
    case instances.size
    when 0
      false
    when 1
      @match.note_standalone_instance_found(instances.first)
      true
    else
      throw 'Unexpected 2+ standalone instances'
    end
  end

  def stand_already_for_default_ref
    log("#{Constants::DECLINED_INSTANCE} - standalone instance " +
                 "exists for def ref for #{@loader_name.simple_name} " +
                 "#{@loader_name.id}")
    Constants::DECLINED
  end

  def unknown_option
    log(
      "Error - unknown option for #{@loader_name.simple_name} #{@loader_name.id}")
    log_error("Unknown option: ##{@match.id} #{@match.loader_name_id}")
    log_error("#{@match.inspect}")
    Constants::ERROR
  end

  def standalone_instance_already_noted?
    return true unless @match.standalone_instance_id.blank?
  end

  def log(payload)
    Loader::Batch::Bulk::JobLog.new(@job, payload, @user).write
  end
end