OmniAuth.config.test_mode = true

class FriendsModuleTest
  extend FriendsModule
end

module FriendsModule
  private
  def facebook_friends
    []
  end
end

SessionsController.to_s

class SessionsController
  private
  def has_permission(permission, token)
    return true
  end
end