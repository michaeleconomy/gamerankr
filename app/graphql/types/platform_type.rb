class Types::PlatformType < Types::BaseObject
  graphql_name "Platform"
  field :id, ID, null: false
  field :name, String, null: false
  field :short_name, String, null: false
  def short_name
    object.short
  end
  # field :ports, [Types::PortType, null: false], null: false
end