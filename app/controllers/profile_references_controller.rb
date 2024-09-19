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
class ProfileReferencesController < ApplicationController
  # Render the add reference form dynamically via AJAX
  def render_add_reference
    profile_item_id = params[:profile_item_id]
    reference_annotation = params[:reference_annotation] || ""
    reference_id = params[:reference_id] || ""
    instance_id = params[:instance_id] || ""
  
    # Find or initialize @instance based on the passed parameters
    @instance = Instance.find(instance_id) if instance_id.present?
  
    render partial: 'instances/tabs/add_reference', 
           locals: { profile_item_id: profile_item_id, 
                     reference_annotation: reference_annotation, 
                     reference_id: reference_id, 
                     instance: @instance }
  end
  

  def create
    Rails.logger.debug "------ Profile Reference Controller Create Action hit."
    
    profile_item_id = params[:profile_item_id] rescue nil
    reference_id = params[:reference_id] rescue nil
    reference_annotation = params[:reference_annotation] rescue nil  # New annotation field

    Rails.logger.debug "Parsed profile_item_id: #{profile_item_id}"
    Rails.logger.debug "Parsed reference_id: #{reference_id}"
    Rails.logger.debug "Parsed reference_annotation: #{reference_annotation}"

    # Attempt to find an existing ProfileReference
    @profile_reference = Profile::ProfileReference.find_by(profile_item_id: profile_item_id, reference_id: reference_id)

    if @profile_reference
      # Update existing ProfileReference
      Rails.logger.debug "Updating Profile Reference with profile_item_id: #{profile_item_id} and reference_id: #{reference_id}"
      
      @profile_reference.annotation = reference_annotation
      @profile_reference.updated_by = current_user_id
  
      if @profile_reference.save
        render json: { message: 'Profile reference updated successfully.', reference: @profile_reference }, status: :ok
      else
        render json: { errors: @profile_reference.errors.full_messages }, status: :unprocessable_entity
      end
    else
      # Create a new ProfileReference
      Rails.logger.debug "Creating a new Profile Reference."

      @profile_reference = Profile::ProfileReference.new(
        profile_item_id: profile_item_id,
        reference_id: reference_id,
        annotation: reference_annotation,  # Assign annotation to the annotation column
        created_by: current_user_id,
        updated_by: current_user_id
      )

      if @profile_reference.save
        Rails.logger.debug "New Profile Reference ID: #{@profile_reference.id}"  # Log the ID of the newly created record
        render json: { message: 'Profile reference created successfully.', reference: @profile_reference }, status: :created
      else
        render json: { errors: @profile_reference.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end


  private

  def current_user_id
    current_user&.id || 'system'
  end
end
