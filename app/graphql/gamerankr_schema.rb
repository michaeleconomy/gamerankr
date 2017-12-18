GamerankrSchema = GraphQL::Schema.define do
  default_max_page_size 30

  mutation(Types::MutationType)
  query(Types::QueryType)
  
  use GraphQL::Batch
end
