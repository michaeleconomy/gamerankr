# http://store.steampowered.com/search/?term=BLAH&category1=998
class Search::AndroidMarketplaceSearch
  
  extend LoggerModule
  include HTTParty
  base_uri 'http://store.steampowered.com'
  
  def self.for(query, options = {})
    logger.info "doing steam search for #{query}, #{options.inspect}"
    
    response = get('/search/',
      :query => {
        :term => query,
        :category1 => 998
        })
    parsed_response = Nokogiri::HTML(response.body)
    parsed_response.css("a.search_result_row").collect do |result|
      parse_item(result)
    end.compact
  end
  
  def self.parse_item(result)
    # title = result.css(".search_name h4").first.content
    result.attributes["href"] =~ /http:\/\/store\.steampowered\.com\/app\/(\d+)\//
    steam_id = $1.to_i
    
    details = get_item_details steam_id
    
    old_stesteam_port = SteamPort.find_by_steam_id(steam_id)
    if old_stesteam_port
      logger.info "found existing port #{old_stesteam_port.id}, updating"
      old_steam_port.price = new_steam_port.price
      old_steam_port.description = new_steam_port.description
      
      old_steam_port.save!
      return old_steam_port.port
    end
    
    new_steam_port = AndroidMarketplacePort.new(
      :am_id => am_id,
      :url => url,
      :price => price,
      :image_url => image_url,
      :description => description)
    
    if genre == "Arcade & Action"
      genre = "Arcade"
    elsif genre == "Brain & Puzzle"
      genre = "Puzzle"
    elsif genre == "Cards & Casino"
      genre = "Cards"
    elsif genre == "Sports Games"
      genre = "Sports"
    end
    
    
    new_port = Port.new(
      :title => title,
      :additional_data => new_steam_port,
      :platform => Platform.find_or_initialize_by_name("Android"))
    
    game = new_port.set_game
    
    new_port.add_publisher(company)
    
    game.add_genre genre
    
    new_port.save!
    
    new_port
  end
  
  def self.get_item_details(steam_id)
    response = get("/app//#{steam_id}")
    parse_item_details(response.body)
  end
  
  def self.parse_item_details(body)
    parsed_response = Nokogiri::HTML(body)
    details = {}
    details[:title] = result.css(".apphub_AppName").first.content
    
    details_block = result.css.(".details_block").first.content
    details_block =~ /search\/\?publisher.*?\>(\w\s+?)\<\/\a\>/
    details[:publisher] = $1
    
    details_block =~ /search\/\?developer.*?\>(\w\s+?)\<\/\a\>/
    details[:developer] = $1
    
    details block =~ /Release Date\:\<\/b\>(.*?)\<br\>/
    release_date_string = $1
    details[:release_date] =
      begin
        Date.parse(release_date_string)
      rescue ArgumentError
        nil
      end
    details[:genres] = result.css(".glance_details a").all.collect(&:content)
    
    price_s = result.css(".game_purchase_price").first.content
    details[:price] = price_s.gsub(/[^\w]/, "").to_i
    
    details[:description] = results.css(".game_description_snippet").first.content
    
    #TODO, grab screenshots
    
    details
  end
end