# app/models/concerns/track_user.rb
module UserTrackable
  extend ActiveSupport::Concern

  included do
    before_create :set_created_by
    before_save :set_updated_by

    class_attribute :current_user_method, default: -> { nil }
  end

  def self.current_user=(user)
    self.current_user_method = -> { user }
  end

  private

  def current_user
    self.class.current_user_method.call
  end

  def set_created_by
    self.created_by ||= current_user&.id if has_attribute?(:created_by)
  end

  def set_updated_by
    self.updated_by = current_user&.id if has_attribute?(:updated_by)
  end
end
