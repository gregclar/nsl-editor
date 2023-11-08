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
class Tree::Workspace::Excluded < ActiveType::Object
  attribute :element_link, :string
  attribute :excluded, :boolean
  attribute :username, :string

  def update
    url = build_url
    payload = { taxonUri: element_link,
                excluded: excluded }
    raise errors.full_messages.first unless valid?

    logger.info "EXCLUDED UPDATE calling #{url} WITH PAYLOAD: #{payload}"

    RestClient.post(url, payload.to_json,
                    { content_type: :json, accept: :json })
  rescue RestClient::ExceptionWithResponse => e
    Rails.logger.error("Tree::Workspace::Excluded error: #{e}")
    raise
  rescue StandardError => e
    Rails.logger.error("Tree::Workspace::Excluded other error: #{e}")
    raise
  end

  def build_url
    Tree::AsServices.excluded_url(username)
  end
end
