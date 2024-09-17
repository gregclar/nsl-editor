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
class ProfileTextsController < ApplicationController
  before_action :set_profile_text, only: %i[show edit update destroy]

  # GET /profile_texts/1
  # GET /profile_texts/1.json
  def show; end

  # GET /profile_texts/new
  def new
    @profile_text = Profile::ProfileText.new
  end

  # GET /profile_texts/1/edit
  def edit
    render "edit"
  end

  # POST /profile_texts
  # POST /profile_texts.json
  def create
    begin
      profile_text_params = params.require(:foa).permit(:instance_id, :display_html, :text_value, :profile_item_id, :profile_text_id, :profile_item_type_id, :profile_product_id, :profile_object_type_id, :is_new)

      # testing error message handling
      # raise StandardError.new("This is a dummy error for testing purposes.")

      # Debugging information
      Rails.logger.debug "&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&& Profile Text Params: #{profile_text_params.inspect}"
  
      is_new = ActiveModel::Type::Boolean.new.cast(profile_text_params[:is_new])
      instance_id = profile_text_params[:instance_id]
      display_html = profile_text_params[:display_html]
      current_time = Time.now
      created_by = updated_by = 'default_user' # Replace with actual user information if available
  
      if is_new
        Rails.logger.debug "^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Profile Text is new ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^"
  
        # Check for existing record
        existing_record_query = ActiveRecord::Base.sanitize_sql_array([<<-SQL, instance_id, display_html])
          SELECT pp.display_html, pi.id as profile_item_id, ptx.id as profile_text_id, ptx.value
          FROM temp_profile.profile_item pi
          JOIN temp_profile.profile_text ptx ON pi.profile_text_id = ptx.id
          JOIN temp_profile.profile_item_type pit ON pi.profile_item_type_id = pit.id
          JOIN temp_profile.profile_product pp ON pit.id = pp.profile_item_type_id
          WHERE pi.instance_id = ? AND pp.display_html = ?;
        SQL
  
        existing_record = ActiveRecord::Base.connection.execute(existing_record_query).first
  
        if existing_record
          Rails.logger.debug "............................... Profile Text is new ................................"
          error_message = "The #{display_html} record is existent for instance: #{instance_id}"
          Rails.logger.debug "Error: #{error_message}"
          respond_to do |format|
            format.json { render json: { success: false, error: error_message, display_html: display_html }, status: :unprocessable_entity }
          end
          return
        end
  
        # Find the correct profile_item_type_id using display_html
        result = ActiveRecord::Base.connection.execute(ActiveRecord::Base.sanitize_sql_array([<<-SQL, display_html]))
          SELECT pit.id
          FROM temp_profile.profile_product pp
          JOIN temp_profile.profile_item_type pit ON pp.profile_item_type_id = pit.id
          WHERE pp.display_html = ?;
        SQL
  
        profile_item_type_id = result.first['id']
  
        # Get the product_id from profile_product_id
        profile_product_id = profile_text_params[:profile_product_id]
        product_result = ActiveRecord::Base.connection.execute(ActiveRecord::Base.sanitize_sql_array([<<-SQL, profile_product_id]))
          SELECT product_id
          FROM temp_profile.profile_product
          WHERE id = ?;
        SQL
  
        product_id = product_result.first['product_id']
  
        # Create new profile_text
        profile_text_result = ActiveRecord::Base.connection.execute(ActiveRecord::Base.sanitize_sql_array([<<-SQL, profile_text_params[:text_value], current_time, created_by, current_time, updated_by]))
          INSERT INTO temp_profile.profile_text (value, created_at, created_by, updated_at, updated_by)
          VALUES (?, ?, ?, ?, ?)
          RETURNING id;
        SQL
        profile_text_id = profile_text_result.first['id']
        Rails.logger.debug "Created Profile Text with ID: #{profile_text_id}"
  
        # Create new profile_item linked to the new profile_text and profile_item_type_id
        profile_item_result = ActiveRecord::Base.connection.execute(ActiveRecord::Base.sanitize_sql_array([<<-SQL, instance_id, profile_text_id, profile_item_type_id, product_id, profile_text_params[:profile_object_type_id], current_time, created_by, current_time, updated_by]))
          INSERT INTO temp_profile.profile_item (instance_id, profile_text_id, profile_item_type_id, product_id, profile_object_type_id, created_at, created_by, updated_at, updated_by)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
          RETURNING id;
        SQL
        profile_item_id = profile_item_result.first['id']
        Rails.logger.debug "Created Profile Item with ID: #{profile_item_id}"
  
        respond_to do |format|
          format.json { render json: { message: 'Profile Text was successfully created.', profile_text_id: profile_text_id, profile_item_id: profile_item_id, display_html: display_html }, status: :ok }
        end
      else
        Rails.logger.debug "################################## Profile Text is not new"
        profile_item_id = profile_text_params[:profile_item_id]
        # Logic for updating existing profile text
        profile_text_id = profile_text_params[:profile_text_id]
        ActiveRecord::Base.connection.execute(ActiveRecord::Base.sanitize_sql_array([<<-SQL, profile_text_params[:text_value], current_time, updated_by, profile_text_id]))
          UPDATE temp_profile.profile_text
          SET value = ?, updated_at = ?, updated_by = ?
          WHERE id = ?;
        SQL
  
        respond_to do |format|
          format.json { render json: { message: 'Profile Text was successfully updated.', profile_item_id: profile_item_id, profile_text_id: profile_text_id, display_html: display_html }, status: :ok }
        end
      end
  
    rescue StandardError => e
      @message = e.to_s
      Rails.logger.debug "Error: #{@message}"
      respond_to do |format|
        format.json { render json: { success: false, error: @message, display_html: profile_text_params[:display_html] }, status: :unprocessable_entity }
      end
    end
  end
  

  # PATCH/PUT /profile_texts/1
  # PATCH/PUT /profile_texts/1.json
  def update
    @message = "No change"
    really_update if changed?
  end

  # DELETE /profile_texts/1
  # DELETE /profile_texts/1.json
  def destroy
    if @profile_text.destroy
      render :destroy
    else
      @message = "Could not delete that record."
      render "update_failed", status: :unprocessable_entity
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_profile_text
    @profile_text = Profile::ProfileText.find(params[:id])
  end

  # only allow the white list through.
  def profile_text_params
    params.require(:profile_text).permit(:text, :index, :instance_id, :value, :is_new)
  end

  def changed?
    @profile_text.value != profile_text_params[:value]
  end

  def really_update
    if @profile_text.update(profile_text_params)
      @message = "Updated"
      render :update
    else
      raise("Not updated")
    end
  rescue StandardError => e
    @message = e.to_s
    render :update_failed, status: :unprocessable_entity
  end
end
