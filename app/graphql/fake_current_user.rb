class FakeCurrentUser

  class AuthorizationError < Exception
  end

  def self.method_missing(m, *args, &block)

    # raise AuthorizationError.new("user is not signed in!")
    raise GraphQL::ExecutionError, "sign in required"
  end
end