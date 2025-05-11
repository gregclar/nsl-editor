class ProfileItems::Links::UpdateService < BaseService

  validate :draft_profile_item

  attr_reader :profile_item, :profile_text

  def initialize(user:, profile_item:, params:)
    super(params)
    @user = user
    @profile_item = profile_item
  end

  def execute
    return unless valid?

    ActiveRecord::Base.transaction do
      create_profile_text
      update_profile_item
      raise ActiveRecord::Rollback if errors.any?
    end
  end

  private

  attr_reader :user

  def draft_profile_item
    return if profile_item.is_draft
    errors.add(:base, "Cannot update a published profile item")
  end

  def create_profile_text
    @profile_text = Profile::ProfileText.new(value_md: profile_item.profile_text.value_md, value: profile_item.profile_text.value)
    @profile_text.current_user = user
    @profile_text.save
    errors.merge!(@profile_text.errors) if @profile_text.errors.any?
  end

  def update_profile_item
    profile_item.current_user = user
    profile_item.assign_attributes(
      source_profile_item_id: nil,
      statement_type: Profile::ProfileItem::STATEMENT_TYPES[:fact],
      profile_text_id: profile_text.id
    )
    profile_item.save
    errors.merge!(profile_item.errors) if profile_item.errors.any?
  end
end
