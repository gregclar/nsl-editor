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
      message = 'No comment change'
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
end
