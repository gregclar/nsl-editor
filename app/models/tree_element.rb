# frozen_string_literal: true

require 'open-uri'

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

#  A tree element - holds the taxon information
class TreeElement < ActiveRecord::Base
  self.table_name = "tree_element"
  self.primary_key = "id"
  self.sequence_name = "nsl_global_seq"

  belongs_to :instance, class_name: "Instance"

  belongs_to :name, class_name: "Name"

  has_many :tree_version_elements,
           foreign_key: "tree_element_id"

  has_and_belongs_to_many :dist_entries,
                          class_name: "DistEntry",
                          join_table: "tree_element_distribution_entries",
                          foreign_key: "tree_element_id"

  def display_as
    'TreeElement'
  end

  def fresh?
    false
  end

  def has_parent?
    false
  end

  def record_type
    'TreeElement'
  end

  # split the diff to get just the before part
  def self.before_html(sr)
    fred = self.diff_html(sr)
    fred = fred.sub(/<div class="diffAfter">.*/m,'') unless fred.blank?
    fred = 'nothing found' if fred.blank?
    fred
  end

  # split the diff to get just the after part
  def self.after_html(sr)
    fred = self.diff_html(sr)
    fred = fred.sub(/.*<div class="diffAfter">/m,'<div class="diffAfter">') unless fred.blank?
    fred = 'nothing found' if fred.blank?
    fred
  end

  def self.diff_html(sr)
    if sr.operation == 'removed'
      sr.synonyms_html
    elsif sr.operation == 'added'
      sr.synonyms_html
    else
      #e1 = "/tree/#{sr.tv_id}/#{sr.id}"
      #e2 = "/tree/#{TreeVersion.find(sr.tv_id).previous_version_id}/#{derived_prev_element_id}"
      e1= sr.previous_tve
      e2= sr.current_tve
      url = "#{Rails.configuration.services_clientside_root_url}tree-version/diff-element?e1=#{CGI.escape(e1)}&e2=#{CGI.escape(e2)}&embed=true"
      open(url, "Accept" => "text/html") {|f| f.read }
    end
  #rescue => e
  #  logger.error('TreeElement#diff_html')
  #  logger.error(e)
  #  'Failed to retrieve details'
  end

  def self.diff_html_old(sr)
    if sr.operation == 'removed'
      sr.synonyms_html
    elsif sr.operation == 'added'
      sr.synonyms_html
    else
      e1 = "/tree/#{sr.tv_id}/#{sr.id}"
      derived_prev_element_id = TreeElement.find(sr.id).previous_element_id
      e2 = "/tree/#{TreeVersion.find(sr.tv_id).previous_version_id}/#{derived_prev_element_id}"
      url = "#{Rails.configuration.services_clientside_root_url}tree-version/diff-element?e1=#{CGI.escape(e1)}&e2=#{CGI.escape(e2)}&embed=true"
      if derived_prev_element_id.blank?
        "Could not identify previous element"
      else
        open(url, "Accept" => "text/html") {|f| f.read }
      end
    end
  rescue => e
    logger.error('TreeElement#diff_html')
    logger.error(e)
    'Failed to retrieve details'
  end

  def self.dist_options
    DistEntry.all.sort do |a, b|
      a.sort_order <=> b.sort_order
    end.collect(&:display)
  end

  def distribution_value
    profile[distribution_key]["value"]
  end

  def distribution?
    distribution_key.present?
  end

  def distribution_key
    profile_key(/Dist/)
  end

  def dist_options_disabled
    disabled_options = []
    all = DistEntry.all
    for n in dist_entries.collect(&:region)
      disabled_options.concat(all.find_all {|opt| opt.dist_region.name == n}.collect(&:display))
    end
    disabled_options
  end

  def current_dist_options
    dist_entries.collect(&:display)
  end

  def construct_distribution_string
    dist_entries
        .sort {|a, b| a.dist_region.sort_order <=> b.dist_region.sort_order}
        .collect(&:entry)
        .join(', ')
  end

  def comment?
    comment_key.present?
  end

  def comment_key
    profile_key(/Comment/)
  end

  def comment_value
    profile[comment_key]["value"]
  end

  def profile_value(key_string)
    key = profile_key(key_string)
    if key
      profile[key]["value"]
    else
      ""
    end
  end

  def profile_key(key_string)
    profile.keys.find {|key| key_string == key} if profile.present?
  end
end
