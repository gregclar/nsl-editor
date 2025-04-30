# frozen_string_literal: true

module Loader::NamesHelper
  def build_reason_to_disable(loader_name, matching_name)
    reason_to_disable = "[Radio button is disabled because "
    reason_to_disable += "matching name has no primary instance; " unless matching_name.has_primary_instance?
    reason_to_disable += "matching name is a duplicate; " if matching_name.duplicate?
    reason_to_disable += "this synonym has no type; " if loader_name.synonym_without_synonym_type?
    reason_to_disable += "match cannot be cleared; " unless loader_name.can_clear_matches?
    reason_to_disable += "]"
    reason_to_disable.sub!("; ]", "]")
    reason_to_disable
  end

  def ref_instance_choice?(loader_name, matching_name)
    loader_name.loader_name_matches.where(name_id: matching_name.id).first.instance_choice_confirmed
  end

  def row_of_formatted_text(text)
    return '' if text.blank?

    %Q(<tr><td colspan="9"><span class="review loader-name remark-to-reviewers">#{text}</span></td></tr>)
  end

  def indented_row_of_formatted_text(text, trailing_tags = '')
    return '' if text.blank?

    %Q(<tr><td width-1-percent"></td><td colspan="9"><span class="review loader-name remark-to-reviewers">#{text}</span></td></tr>#{trailing_tags})
  end
end
