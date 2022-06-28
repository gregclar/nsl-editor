#
#
#
#
#
# Tree Element Profile 
module Concerns::Tree::Element::Profile extend ActiveSupport::Concern

  def profile_value(key_string)
    key = profile_key(key_string)
    if key
      profile[key]["value"]
    else
      ""
    end
  end

  def profile_key(pkey)
    return nil unless profile.present?

    if pkey.is_a? String then
      profile.keys.find {|key| key == pkey}
    elsif pkey.is_a? Regexp then
      profile.keys.find {|key| key =~ pkey}
    else 
      raise 'Not a string or a regexp....'
    end
  end

  # Escape any double quotes
  # SQL quote single quotes
  def quote_string_for_sql(s)
    ActiveRecord::Base.connection.quote(s)
  end

  def update_comment(comment_param, username)
    if comment_param.blank?
      return apply_blank_comment(username)
    else
      return apply_non_blank_comment(comment_param, username)
    end
    return message, refresh || false
  end

  def apply_blank_comment(username)
    if profile.blank?
      message = 'Empty comment for empty profile - nothing to do'
    elsif comment_value.blank?
      message = 'No change to comment'
    else
      message = 'You want to delete the comment'
      remove_comment_directly
      message = 'Comment removed'
      refresh = true
    end
    return message, refresh || false
  end

  def apply_non_blank_comment(comment_param, username)
    refresh = true
    if comment_value.blank?
      return add_comment(comment_param, username) 
    elsif comment_value != comment_param
      update_comment_directly(comment_param, username)
      message = 'Comment changed'
    else
      message = 'No change to comment'
      refresh = false
    end
    return message, refresh || false
  end

  def add_comment(comment_param, username)
    if profile.blank?
      add_profile_and_comment(comment_param, username) 
    elsif comment_value.blank?
      add_comment_to_profile(comment_param, username)
    end
    message = "Comment added"
    refresh = true
    return message, refresh || false
  end

  def update_distribution(dist_param, username)
    message, refresh = '', false
    if excluded?
      ActiveRecord::Base.transaction do
        message, refresh = update_excluded_distribution(dist_param, username)
      rescue => e
        Rails.logger.error("Rolling back transaction in update_distribution for excluded")
        Rails.logger.error(e.to_s)
        message = "Error: #{e.to_s}"
        refresh = false
        raise ActiveRecord::Rollback
      end
    else
      ActiveRecord::Base.transaction do
        message, refresh = update_accepted_distribution(dist_param, username)
      rescue => e
        Rails.logger.error("Rolling back transaction in update_distribution")
        Rails.logger.error(e.to_s)
        message = "Error: #{e.to_s}"
        refresh = false
        raise ActiveRecord::Rollback
      end
    end
    return message, refresh
  end

  def update_excluded_distribution(dist_param, username)
    message = ''
    unless dist_param.blank?
      throw 'Distribution changes for excluded names not implemented'
    end
    return message
  end

  def update_accepted_distribution(dist_param, username)
    if dist_param.blank?
      return update_dist_with_blank_param(username)
    else # dist param exists
      return update_dist_with_non_blank_param(dist_param, username)
    end
  end
  
  def update_dist_with_non_blank_param(dist_param, username)
    if profile.blank?
      return add_dist_with_profile(dist_param, username)
    elsif distribution_value.blank?
      return add_dist_to_profile(dist_param, username)
    elsif distribution_value != dist_param
      return change_dist(dist_param, username)
    else 
      return "No change to distribution", false
    end
  end

  def update_dist_with_blank_param(username)
    if profile.blank?
      message = 'Empty distribution for empty profile - nothing to do'
    elsif distribution_value.blank?
      message = 'No distribution change'
    else
      remove_distribution_directly
      te = Tree::Element.find(self.id)
      te.delete_tedes
      message = 'Distribution removed'
      refresh = true
    end
    return message, refresh
  end

  def add_dist_to_profile(dist_param, username)
    new_cleaned = Tree::Element.cleanup_distribution_string(dist_param)
    Tree::Element.validate_distribution_string(new_cleaned)
    add_profile_distribution_directly(username, new_cleaned)
    te = Tree::Element.find(self.id)
    te.apply_string_to_tedes
    return 'Distribution added', true
  end

  def add_dist_with_profile(dist_param, username)
    new_cleaned = Tree::Element.cleanup_distribution_string(dist_param)
    Tree::Element.validate_distribution_string(new_cleaned)
    add_profile_with_distribution_directly(username, new_cleaned)
    te = Tree::Element.find(self.id)
    te.apply_string_to_tedes
    return 'Distribution added to a fresh profile', true
  end

  def change_dist(dist_param, username)
    message = 'Distribution has changed'
    new_cleaned = Tree::Element.cleanup_distribution_string(dist_param)
    if new_cleaned == distribution_value
      message =
        'No change in standardardised format of accepted taxon distribution'
    else
      Tree::Element.validate_distribution_string(new_cleaned)
      update_distribution_directly(new_cleaned, username)
      te = Tree::Element.find(self.id)
      te.apply_string_to_tedes
      refresh = true
      message = 'Distribution changed'
    end
    return message, refresh
  end
end
