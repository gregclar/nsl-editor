class Users::ProfileContexts::BaseAccess
  
  attr_reader :user, :product

  def initialize(user)
    @user = user
    @product = "unknown"
  end

  def viewer?
    false
  end

  def editor?
    false
  end

  def instance_editor?
    false
  end

  def super_editor?
    false
  end
end