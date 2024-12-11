class Users::ProfileContexts::ApniAccess < Users::ProfileContexts::BaseAccess
  
  def initialize(user)
    super
    @product = "APNI"
  end

  # Add custom methods

  def viewer?
    true
  end

  def instance_editor?
    false
  end

  def super_editor?
    true
  end
end