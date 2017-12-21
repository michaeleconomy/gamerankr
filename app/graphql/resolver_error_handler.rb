class ResolverErrorHandler

  def initialize(resolver)
    @r = resolver
  end

  def call(obj, args, ctx)
    @r.call(obj, args, ctx)
  rescue ActiveRecord::RecordNotFound => e
    GraphQL::ExecutionError.new("Missing Record: #{e.message}")
  rescue FakeCurrentUser::AuthorizationError => e
    GraphQL::ExecutionError.new("sign in required")
  rescue ActiveRecord::RecordInvalid => e
    # return a GraphQL error with validation details
    messages = e.record.errors.full_messages.join("\n")
    GraphQL::ExecutionError.new("Validation failed: #{messages}")
  rescue StandardError => e
    # handle all other errors
    Rails.logger.error "graphql exception caught: #{e} \n#{e.backtrace.join("\n")}"
    Raven.capture_exception(e)
    
    GraphQL::ExecutionError.new("Unexpected error!")
  end
end