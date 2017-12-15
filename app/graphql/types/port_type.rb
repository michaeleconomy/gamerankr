def additional_data_type_loader(obj)
  klass = 
    case obj.additional_data_type
    when "AmazonPort"
      AmazonPort
    when "SteamPort"
      SteamPort
    when "GiantBombPort"
      GiantBombPort
    when "ITunesPort"
      GiantBombPort
    when "AndroidMarketplacePort"
      AndroidMarketplacePort
    else
      nil
    end
  klass && RecordLoader.for(klass).load(obj.additional_data_id)
end

Types::PortType = GraphQL::ObjectType.define do
  
  name "Port"
  field :id, !types.ID
  field :game, !Types::GameType
  field :platform, !Types::PlatformType do
    resolve -> (obj, args, ctx) {
      RecordLoader.for(Platform).load(obj.platform_id)
    }
  end
  field :title, !types.String
  field :rankings, !types[!Types::RankingType]
  field :small_image_url, types.String do
    resolve -> (obj, args, ctx) {
      additional_data_type_loader(obj).then do |additional_data|
        additional_data && additional_data.small_image_url
      end
    }
  end
  field :large_image_url, types.String do
    resolve -> (obj, args, ctx) {
      additional_data_type_loader(obj).then do |additional_data|
        additional_data && additional_data.large_image_url
      end
    }
  end
end