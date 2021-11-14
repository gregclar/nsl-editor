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
class Search::Loader::Name::FieldRule
  RULES = {
    "scientific-name:"    => { where_clause: "lower(scientific_name) like ? ",
                                 trailing_wildcard: true,
                                 leading_wildcard: true,
                                 order: "scientific_name"},
    "batch-id:"           => { where_clause: "loader_batch_id = ? ",
                               order: "seq"},
    "batch-name:"           => { where_clause: "loader_batch_id = (select id from loader_batch where lower(name) = ?)  ",
                               order: "seq"},
    "default-batch-name:"   => { where_clause: "loader_batch_id = (select id from loader_batch where lower(name) = ?)  ",
                               order: "seq"},
    "id:"                 => { multiple_values: true,
                               where_clause: "id = ? ",
                               multiple_values_where_clause: " id in (?)",
                               order: "seq"},
    "ids:"                => { multiple_values: true,
                               where_clause: " id = ?",
                               multiple_values_where_clause: " id in (?)",
                               order: "seq"},
    "has-comment:"        => { where_clause: "exists (select null from name_review_comment nrc where nrc.loader_name_id = loader_name.id)",
                               order: "seq"},
  }.freeze
end
