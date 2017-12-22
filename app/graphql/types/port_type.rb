def additional_data_type_loader(obj)
  klass = 
    case obj.additional_data_type
    when "AmazonPort"
      AmazonPort
    when "SteamPort"
      SteamPort
    when "GiantBombPort"
      GiantBombPort
    when "ItunesPort"
      ItunesPort
    when "AndroidMarketplacePort"
      AndroidMarketplacePort
    when nil
      return nil
    else
      raise "don't know how to load additional_data_type: #{obj.additional_data_type}"
    end
  RecordLoader.for(klass).load(obj.additional_data_id)
end

Types::PortType = GraphQL::ObjectType.define do
  
  name "Port"
  field :id, !types.ID
  field :game, !Types::GameType
  field :platform, !Types::PlatformType do
    resolve -> (obj, args, ctx) do
      RecordLoader.for(Platform).load(obj.platform_id)
    end
  end
  field :title, !types.String
  field :rankings, !types[!Types::RankingType]
  field :small_image_url, types.String do
    resolve -> (obj, args, ctx) do
      loader = additional_data_type_loader(obj)
      return nil unless loader
      loader.then do |additional_data|
        additional_data && additional_data.small_image_url
      end
    end
  end
  field :medium_image_url, types.String do
    resolve -> (obj, args, ctx) do
      loader = additional_data_type_loader(obj)
      return nil unless loader
      loader.then do |additional_data|
        additional_data && additional_data.medium_image_url
      end
    end
  end
  field :large_image_url, types.String do
    resolve -> (obj, args, ctx) do
      loader = additional_data_type_loader(obj)
      return nil unless loader
      loader.then do |additional_data|
        additional_data && additional_data.large_image_url
      end
    end
  end
end