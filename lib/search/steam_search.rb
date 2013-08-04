# http://store.steampowered.com/search/?term=BLAH&category1=998
class Search::SteamSearch
  
  extend LoggerModule
  include HTTParty
  base_uri 'http://store.steampowered.com'
  cookies :lastagecheckage => "6-July-1983", :birthtime => "426322801"
  
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
    url = result.attributes["href"].to_s
    logger.info "asfgasf -- #{url}"
    if url !~ /http:\/\/store\.steampowered\.com\/app\/(\d+)\//
      return
    end
    steam_id_s = $1
    logger.info "steam_id_s: #{steam_id_s}"
    steam_id = steam_id_s.to_i
    
    if steam_id == 0
      logger.info "couldn't find steam id out of url "
      return
    end
    
    details = get_item_details steam_id
    
    old_steam_port = SteamPort.find_by_steam_id(steam_id)
    if old_steam_port
      logger.info "found existing port #{old_stesteam_port.id}, updating"
      old_steam_port.price = details[:price]
      old_steam_port.description = new_steam_port[:description]
      
      old_steam_port.save!
      return old_steam_port.port
    end
    
    new_steam_port = SteamPort.new(
      :steam_id => steam_id,
      :url => url,
      :price => price,
      :image_url => image_url,
      :description => description)

    new_port = Port.new(
      :title => details[:title],
      :additional_data => new_steam_port,
      :platform => Platform.find_or_initialize_by_name("Android"))
    
    game = new_port.set_game
    
    new_port.add_publisher(details[:publisher])
    new_port.add_developer(details[:developer])
    
    details[:genres].each do |genre|
      game.add_genre genre
    end
    
    new_port.save!
    
    new_port
  end
  
  def self.get_item_details(steam_id)
    logger.info "getting more details on #{steam_id}"
    response = get("/app/#{steam_id}")
    parse_item_details(response.body)
  end
  
  def self.parse_item_details(body)
    result = Nokogiri::HTML(body)
    
    File.open('tmp/steam_dmp.txt', 'w') { |file| file.write(body.encode('UTF-8', {:invalid => :replace, :undef => :replace, :replace => '?'})) }
    details = {}
    title = result.css("h1").first.content.to_s
    
    details[:title] = title.gsub(/^Buy /, "")
    logger.info details[:title]
    
    details_block = result.css(".details_block").first.inner_html.to_s
    logger.info "#{details_block}"
    details_block =~ /publisher.*?\>(.+?)\<\/a\>/
    details[:publisher] = $1
    
    details_block =~ /search\/\?developer.*?\>(.+?)\<\/a\>/
    details[:developer] = $1
    
    details_block =~ /Release Date\:\<\/b\>(.*?)\<br\>/
    release_date_string = $1
    details[:release_date] =
      begin
        Date.parse(release_date_string)
      rescue ArgumentError
        nil
      end
    details[:genres] = result.css(".glance_details a").collect(&:content)
    
    price_s = result.css(".game_purchase_price").first.content.to_s
    details[:price] = price_s.gsub(/[^\w]/, "").to_i
    
    details[:description] = result.css(".game_description_snippet").first.content.to_s
    
    details[:platforms] = body.scan(/(\w+) System Requirements/).flatten
    if details[:platforms].empty?
      details[:platforms] << "PC"
    end
    
    #TODO, grab screenshots
    
    details
    
    logger.info "#{details}"
    return nil
  end
end