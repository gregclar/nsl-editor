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
# 2025-04-01 11:51:01.723 [fyi] r6editor Completed 200 OK in 29ms (Views: 13.8ms | ActiveRecord: 9.8ms | Allocations: 18493) (pid:44559)
# 2025-04-01 11:51:03.214 [fyi] r6editor Started POST "/nsl/editor/user_product_roles" for ::1 at 2025-04-01 11:51:03 +1100 (pid:44559)
# 2025-04-01 11:51:03.231 [omg] r6editor SyntaxError (/Users/gclarke/anbg/rails/nedruby/app/controllers/users/product_roles_controller.rb:105: syntax error, unexpected `end'):

# app/controllers/users/product_roles_controller.rb:105: syntax error, unexpected `end' (pid:44559)
# 2025-04-01 11:51:27.482 [fyi] r6editor Started POST "/nsl/editor/user_product_roles" for ::1 at 2025-04-01 11:51:27 +1100 (pid:44559)
# 2025-04-01 11:51:27.618 [omg] r6editor AbstractController::ActionNotFound (The action 'create' could not be found for Users::ProductRolesController):

class User::ProductRolesController < ApplicationController
  before_action :find_upr, only: %i[destroy]

  # POST 
  def create
    if user_product_role_params[:role_id].blank? then 
      @upr = User::ProductRole.new(user_product_role_params)
      render :new_with_roles
    else
      @upr = User::ProductRole.create(user_product_role_params, current_user.username)
    end
  rescue StandardError => e
    @error = e.to_s
    logger.error("User::ProductRolesController#create:rescuing exception #{@error}")
    render "create_error", status: :unprocessable_entity
  end

  # POST /users
  # def update
    # @message = @user.update_if_changed(user_params, current_user.username)
    # render "update"
  # rescue => e
    # logger.error("Review.update:rescuing exception #{e}")
    # @error = e.to_s
    # render "update_error", status: :unprocessable_entity
  # end
# 
  def destroy
    @upr.destroy
  end

  def choose_product_for_role
  end

  private

  def find_upr
    @upr = User::ProductRole.find([params[:user_id], params[:product_id], params[:role_id]])
  # rescue ActiveRecord::RecordNotFound
    # flash[:alert] = "We could not find the user record."
    # redirect_to user_path
  end

  def user_product_role_params
    params.require(:user_product_role).permit(:user_id, :role_id, :product_id)
  end
end
