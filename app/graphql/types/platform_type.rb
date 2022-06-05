class Types::PlatformType < Types::BaseObject
  graphql_name "Platform"
  field :id, ID, null: false
  field :name, String, null: false
  # field :ports, [Types::PortType, null: false], null: false
end