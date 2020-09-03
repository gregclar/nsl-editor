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
class OrchidsBatchController < ApplicationController

  def create_preferred_matches
    prefix = 'create-preferred-matches-'
    records = Orchid.create_preferred_matches_for_accepted_taxa(params[:taxon_string], @current_user.username)
    @message = "Created #{records} matches for #{params[:taxon_string]}"
    render 'create', locals: {message_container_id_prefix: prefix }
  rescue => e
    logger.error("OrchidsBatchController#create_preferred_matches: #{e.to_s}")
    logger.error e.backtrace.join("\n")
    @message = e.to_s.sub(/uncaught throw/,'').gsub(/"/,'')
    render 'error', locals: {message_container_id_prefix: prefix }
  end

  def create_instances_for_preferred_matches
    prefix = 'create-draft-instances-'
    records = Orchid.create_instance_for_preferred_matches_for(params[:taxon_string], @current_user.username)
    @message = "Created #{records} draft instances for #{params[:taxon_string]}"
    render 'create', locals: {message_container_id_prefix: prefix }
  rescue => e
    logger.error("OrchidsBatchController#create_instances_for_preferred_matches: #{e.to_s}")
    logger.error e.backtrace.join("\n")
    @message = e.to_s.sub(/uncaught throw/,'').gsub(/"/,'')
    render 'error', locals: {message_container_id_prefix: prefix }
  end

  def add_instances_to_draft_tree
    prefix = 'add-instances-to-tree-'
    logger.debug("#add_instances_to_draft_tree start")
    records, errors = Orchid.add_to_tree_for(@working_draft, params[:taxon_string], @current_user.username)
    logger.debug("records added to tree: #{records}")
    @message = %Q(Added #{records} #{'instance'.pluralize(records)})
    @message += %Q( to tree "#{@working_draft.draft_name}" tree for orchids )
    @message += %Q( matching "#{params[:taxon_string]}")
    if errors.strip.blank?
      @errors = nil
    else
      @errors = %Q(Errors not blank: #{errors.length})
    end
    render 'create', locals: {message_container_id_prefix: prefix }
  rescue => e
    logger.error("OrchidsBatchController#add_instances_to_draft_tree: #{e.to_s}")
    logger.error e.backtrace.join("\n")
    @message = e.to_s.sub(/uncaught throw/,'').gsub(/"/,'')
    render 'error', locals: {message_container_id_prefix: prefix }
  end

  private

  def orchid_batch_params
    return nil if params[:orchid_batch].blank?
    params.require(:orchid_batch).permit(:taxon_string)
  end

  def debug(msg)
    logger.debug('OrchidsBatchController')
  end
end
