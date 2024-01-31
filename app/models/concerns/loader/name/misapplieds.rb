module Loader::Name::Misapplieds
  extend ActiveSupport::Concern

  def partial_misapplied?
    synonym_type.match?(/pro parte/)
  end
end
