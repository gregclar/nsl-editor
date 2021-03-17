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

#   Taxonomy element comments are part of reviews of tree (taxonomy) versions
class TaxonomyElementCommentsController < ApplicationController

  def create
    @taxonomy_element_comment = TaxonomyElementComment.create(
                                      taxonomy_element_comment_params,
                                      current_user.username)
    render "create.js"
  rescue => e
    logger.error("Controller:TaxonomyElementComments:create:rescuing exception #{e}")
    @error = e.to_s
    render "create_error.js", status: :unprocessable_entity
  end

  private

  def taxonomy_element_comment_params
    params.require(:taxonomy_element_comment).permit(:comment,
                                                     :tree_element_id,
                                                     :taxonomy_version_review_period_id)
  end
end
