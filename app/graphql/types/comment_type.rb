Types::CommentType = GraphQL::ObjectType.define do
  name "Comment"
  field :id, !types.ID
  field :created_at, !types.String
  field :comment, !types.String
  field :user, !Types::UserType do
    resolve -> (obj, args, ctx) do
      RecordLoader.for(User).load(obj.user_id)
    end
  end
  field :resource, !Types::RankingType do # TODO - need to make this line polymorphic
    resolve -> (obj, args, ctx) do
      case(obj.resource_type)
      when "Ranking"
        return RecordLoader.for(Ranking).load(obj.resource_id)
      else
        raise "I don't know how to load resource_type #{obj.resource_type}"
      end
    end
  end
end