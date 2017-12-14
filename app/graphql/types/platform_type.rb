Types::PlatformType = GraphQL::ObjectType.define do
  name "Platforms"
  field :id, !types.ID
  field :name, !types.String
  field :ports, !types[Types::PortType]
end