class Types::CommentType < Types::BaseObject
  graphql_name "Comment"
  field :id, ID, null: false
  field :created_at, String, null: false, camelize: false
  field :comment, String, null: false
  
  field :user, Types::UserType, null: false
  def user
    RecordLoader.for(User).load(object.user_id)
  end

  field :resource, Types::RankingType, null: false # TODO - need to make this line polymorphic
  def resource
    case(object.resource_type)
    when "Ranking"
      return RecordLoader.for(Ranking).load(object.resource_id)
    else
      raise "I don't know how to load resource_type #{object.resource_type}"
    end
  end
end