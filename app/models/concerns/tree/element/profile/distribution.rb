#
# Tree Element Profile 
module Concerns::Tree::Element::Profile::Distribution extend ActiveSupport::Concern

  def distribution
    return nil if profile.blank?

    profile[distribution_key]
  end

  def distribution_value
    return nil if profile.blank?

    return nil if profile[distribution_key_for_insert].blank?

    profile[distribution_key]["value"]
  end

  def distribution?
    distribution_key.present?
  end

  def distribution_key
    profile_key(/Dist/)
  end

  def distribution_key_for_insert
    tves.first.tree_version.tree.distribution_key
  end

  def dist_options_disabled
    disabled_options = []
    all = DistEntry.all
    for n in tede_dist_entries.collect(&:region)
      disabled_options.concat(all.find_all {|opt| opt.dist_region.name == n}.collect(&:display))
    end
    disabled_options
  end

  def current_dist_options
    tede_dist_entries.collect(&:display)
  end

  def construct_distribution_string
    tede_dist_entries
        .sort {|a, b| a.dist_region.sort_order <=> b.dist_region.sort_order}
        .collect(&:entry)
        .join(', ')
  end

  def distribution_as_arr
    distribution_value.split(',').collect {|val| val.strip}
  end

  def add_profile_distribution_directly(username,dist_s)
    throw 'No profile exists' if profile.blank?

    throw 'Profile distribution already exists' unless profile[distribution_key_for_insert].blank?

    key = distribution_key_for_insert
    profile[key] = Hash.new
    profile[key]['value'] = dist_s
    profile[key]['created_at'] = profile[key]['updated_at'] = Time.now
    profile[key]['created_by'] = profile[key]['updated_by'] = username
    save!
    add_missing_tedes
  end

  def add_profile_with_distribution_directly(username,dist_s)
    throw 'Profile exists' unless profile.blank?

    p = Hash.new
    key = distribution_key_for_insert
    p[key] = Hash.new
    p[key]['value'] = dist_s
    p[key]['created_at'] = p[key]['updated_at'] = Time.now
    p[key]['created_by'] = p[key]['updated_by'] = username
    self.profile = p
    save!
    add_missing_tedes
  end

  # note: deliberatly using the update_all method because allows convenient use of jsonb_set 
  # note: no validation
  # note: applies sql directly
  def update_distribution_directly(new_dist_s, user)
    Tree::Element.where(id: self.id).update_all(%Q(profile = jsonb_set(profile,'{"#{distribution_key}","value"}','"#{new_dist_s}"')))
    Tree::Element.where(id: self.id).update_all(%Q(profile = jsonb_set(profile,'{"#{distribution_key}","updated_by"}','"#{user}"')))
    Tree::Element.where(id: self.id).update_all(%Q(profile = jsonb_set(profile,'{"#{distribution_key}","updated_at"}',to_jsonb(to_char(now()::timestamp,'YYYY-MM-DD"T"HH24:MI:SS+#{utc_offset_s}')))))
  end

  def remove_distribution_directly
    Tree::Element.where(id: self.id).update_all(%Q(profile = profile #- '{"#{distribution_key_for_insert}"}'))
    Tree::Element.where(id: self.id).where(profile: {}).update_all(%Q(profile = null))
  end

  included do
    def self.dist_options
      DistEntry.all.sort do |a, b|
        a.sort_order <=> b.sort_order
      end.collect(&:display)
    end

    def self.cleanup_distribution_string(s)
      s = s.strip.chomp(',').split(',').collect {|s| s.strip}
           .sort_by { |s| Tree::Element.region_position(s) || 99 }.uniq.join(', ') 
    end

    def self.validate_distribution_string(s)
      s.split(',').collect{|val| val.strip}.each do |val|
        raise %Q(empty distribution value, likely due to an unnecessary comma) if val.blank?
        raise %Q(Invalid distribution value: "#{val}") unless DistEntry.exists?(display: val.strip)
      end
      self.reject_duplicates(s)
    end

    def self.reject_duplicates(s)
      a = self.remove_bracketed_qualifiers(s)
              .split(',')
              .collect { |e| e = e.strip }
      dupe = a.detect { |e| a.count(e) > 1 }
      raise %Q(duplicate value: '#{dupe}') unless dupe.nil?
    end

    def self.remove_bracketed_qualifiers(s)j
      s.gsub(/\([^\)]*\)/,'')
    end

    # e.g. input dist_entry 'AR (native and naturalised)'
    #      get the sort_order for AR from dist_region
    def self.region_position(dist_entry)
      DistRegion.as_hash[dist_entry.split(' ').first]
    end

  end # includes
end
