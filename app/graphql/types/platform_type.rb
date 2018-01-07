Types::PlatformType = GraphQL::ObjectType.define do
  name "Platform"
  field :id, !types.ID
  field :name, !types.String
  # field :ports, !types[!Types::PortType]
end