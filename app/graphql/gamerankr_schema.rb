require 'graphql/batch'

class GamerankrSchema < GraphQL::Schema
  default_max_page_size 30

  mutation(Types::MutationType)
  query(Types::QueryType)

  # For batch-loading (see https://graphql-ruby.org/dataloader/overview.html)
  use GraphQL::Dataloader
  use GraphQL::Batch

  # GraphQL-Ruby calls this when something goes wrong while running a query:
  def self.type_error(err, context)
    # if err.is_a?(GraphQL::InvalidNullError)
    #   # report to your bug tracker here
    #   return nil
    # end
    super
  end

  # Union and Interface Resolution
  def self.resolve_type(abstract_type, obj, ctx)
    # TODO: Implement this method
    # to return the correct GraphQL object type for `obj`
    raise(GraphQL::RequiredImplementationMissingError)
  end

  # Relay-style Object Identification:

  # Return a string UUID for `object`
  def self.id_from_object(object, type_definition, query_ctx)
    # For example, use Rails' GlobalID library (https://github.com/rails/globalid):
    object.to_gid_param
  end

  # Given a string UUID, find the object
  def self.object_from_id(global_id, query_ctx)
    # For example, use Rails' GlobalID library (https://github.com/rails/globalid):
    GlobalID.find(global_id)
  end


  rescue_from(FakeCurrentUser::AuthorizationError) do |err, obj, args, ctx, field|
    raise GraphQL::ExecutionError, "sign in required"
  end

  rescue_from(ActiveRecord::RecordNotFound) do |err, obj, args, ctx, field|
    raise GraphQL::ExecutionError, "Missing Record: #{err.message}"
  end

  rescue_from(ActiveRecord::RecordInvalid) do |err|
    messages = err.record.errors.full_messages.join("\n")
    raise GraphQL::ExecutionError, "Validation failed: #{messages}"
  end
end
