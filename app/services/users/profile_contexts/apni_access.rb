class Users::ProfileContexts::ApniAccess < Users::ProfileContexts::BaseAccess
  
  def initialize(user)
    super
    @product = Users::ProfileContexts::BaseAccess::PRODUCTS[:apni]
  end

  # Add custom methods

  def profile_view_allowed?
    true
  end

  def instance_edit_allowed?
    user.groups.include?('v2-profile-instance-edit')
  end

  def copy_instance_allowed?
    true
  end

end