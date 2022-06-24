#
# Tree Element Profile 
module Concerns::Tree::Element::Profile::Comment extend ActiveSupport::Concern

  def comment
    profile[comment_key]
  end

  def comment?
    comment_key.present?
  end

  def comment_key
    profile_key(/Comment/)
  end

  def comment_key_for_insert
    tves.first.tree_version.tree.comment_key
  end

  def comment_value
    return nil if profile.blank?

    return nil if profile[comment_key_for_insert].blank?

    profile[comment_key]["value"]
  end

  def update_comment_directly(new_comment, user)
    Rails.logger.debug("update_comment_directly for new_comment: #{new_comment}")
    quoted_comment = quote_string_for_sql(new_comment.to_json)
    Tree::Element.where(id: self.id).update_all(%Q(profile = jsonb_set(profile,'{"#{comment_key}","value"}',#{quoted_comment})))
    Tree::Element.where(id: self.id).update_all(%Q(profile = jsonb_set(profile,'{"#{comment_key}","updated_by"}','"#{user}"')))
    Tree::Element.where(id: self.id).update_all(%Q(profile = jsonb_set(profile,'{"#{comment_key}","updated_at"}',to_jsonb(to_char(now()::timestamp,'YYYY-MM-DD"T"HH24:MI:SS+#{utc_offset_s}')))))
  end

  def remove_comment_directly
    Tree::Element.where(id: self.id).update_all(%Q(profile = profile #- '{"#{comment_key_for_insert}"}'))
    Tree::Element.where(id: self.id).where(profile: {}).update_all(%Q(profile = null))
  end

  def add_profile_and_comment(comment, username)
    throw 'Profile already exists' unless profile.blank?

    comment = Tree::Element::Profile::Comment.new(username, comment)
    p = Hash.new
    p[comment_key_for_insert] = comment.as_hash
    self.profile = p
    save!
  end

  def add_comment_to_profile(comment, username)
    throw 'No profile exists' if profile.blank?

    throw 'Profile comment already exists' unless profile[comment_key_for_insert].blank?

    comment = Tree::Element::Profile::Comment.new(username, comment)
    profile[comment_key_for_insert] = comment.as_hash
    save!
  end
end
