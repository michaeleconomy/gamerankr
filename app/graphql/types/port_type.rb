def additional_data_type_loader(object)
  klass = 
    case object.additional_data_type
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
    when "IgdbGame"
      IgdbGame
    when nil
      return nil
    else
      raise "don't know how to load additional_data_type: #{object.additional_data_type}"
    end
  RecordLoader.for(klass).load(object.additional_data_id)
end

class Types::PortType < Types::BaseObject
  
  graphql_name "Port"
  field :id, ID, null: false
  field :game, Types::GameType, null: false
  field :platform, Types::PlatformType, null: false
  def platform
    RecordLoader.for(Platform).load(object.platform_id)
  end

  field :title, String, null: false
  field :rankings, [Types::RankingType, null: false], null: false
  field :small_image_url, String, camelize: false
  def small_image_url
    loader = additional_data_type_loader(object)
    return nil unless loader
    loader.then do |additional_data|
      additional_data && additional_data.small_image_url
    end
  end

  field :medium_image_url, String, camelize: false
  def medium_image_url
    loader = additional_data_type_loader(object)
    return nil unless loader
    loader.then do |additional_data|
      additional_data && additional_data.medium_image_url
    end
  end

  field :large_image_url, String, camelize: false
  def large_image_url
    loader = additional_data_type_loader(object)
    return nil unless loader
    loader.then do |additional_data|
      additional_data && additional_data.large_image_url
    end
  end

  field :description, String
  def description
    loader = additional_data_type_loader(object)
    return nil unless loader
    loader.then do |additional_data|
      additional_data && additional_data.description
    end
  end
end