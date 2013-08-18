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
      parse_item(result, options[:rescan])
    end.compact
  end
  
  def self.parse_item(result, rescan)
    url = result.attributes["href"].to_s
    if url !~ /http:\/\/store\.steampowered\.com\/app\/(\d+)\//
      return
    end
    steam_id_s = $1
    steam_id = steam_id_s.to_i.to_s
    
    if steam_id == 0
      logger.info "couldn't find steam id out of url "
      return
    end
    
    fetch_steam_id(steam_id, rescan)
  end
  
  def self.fetch_steam_id(steam_id, rescan)
    existing_steam_ports = SteamPort.includes(:port).where(:steam_id => steam_id)
    unless existing_steam_ports.empty? || rescan
      return existing_steam_ports.first.port
    end
    
    details = get_item_details steam_id
    
    if details[:platforms].empty?
      logger.info "no platforms! details:#{details}"
      return
    end
    
    if details[:title].blank?
      logger.info "no title! details:#{details}"
      return
    end
    
    port_found = nil
    game = nil
      
    details[:platforms].delete_if do |platform|
      old_steam_port = SteamPort.find_by(:steam_id => steam_id, :platform => platform)
      if old_steam_port
        logger.info "found existing port #{old_steam_port.id}, updating"
        old_steam_port.price = details[:price]
        old_steam_port.discount_price = details[:discount_price]
        old_steam_port.description = details[:description]
      
        old_steam_port.save!
        game ||= old_steam_port.port.game
        port_found ||= old_steam_port.port
        true
      else
        false
      end
    end

    details[:platforms].each do |platform|
      new_steam_port = SteamPort.new(
        :steam_id => steam_id,
        :platform => platform,
        :price => details[:price],
        :discount_price => details[:discount_price],
        :description => details[:description])

      new_port = Port.new(
        :title => details[:title],
        :additional_data => new_steam_port,
        :platform => Platform.find_or_initialize_by(:name => platform))
        
      new_port.game = game ||= new_port.set_game
      
      new_port.add_publisher(details[:publisher])
      new_port.add_developer(details[:developer])
      
      new_port.save!

      port_found ||= new_port
    end
    
    
    details[:genres].each do |genre|
      game.add_genre genre
    end
    
    port_found
  end
  
  def self.get_item_details(steam_id)
    logger.info "getting more details on #{steam_id}"
    response = get("/app/#{steam_id}")
    parse_item_details(response.body)
  end
  
  def self.clean_price(element)
    return if !element
    element.content.to_s.gsub(/[^\w]/, "").to_i
  end
  
  def self.parse_item_details(body)
    result = Nokogiri::HTML(body)
    
    details = {}
    details[:title] = result.css("span[itemprop=name]").first.content.to_s
    
    details_block = result.css(".details_block").first.inner_html.to_s
    details_block =~ /publisher.*?\>(.+?)\<\/a\>/
    details[:publisher] = $1
    
    details_block =~ /search\/\?developer.*?\>(.+?)\<\/a\>/
    details[:developer] = $1
    
    details_block =~ /Release Date\:\<\/b\>(.*?)\<br\>/
    release_date_string = $1
    if release_date_string
      details[:release_date] =
        begin
          Date.parse(release_date_string)
        rescue ArgumentError
          nil
        end
    end
    details[:genres] = result.css(".glance_details a").collect(&:content)
    
    discount_price_node = result.css(".discount_final_price").first
    if discount_price_node
      details[:discount_price] = clean_price(discount_price_node)
      details[:price] = clean_price(result.css(".discount_original_price").first)
    else
      details[:price] = clean_price(result.css(".game_purchase_price").first)
    end
    
    details[:description] = result.css(".game_description_snippet").first.content.to_s
    
    details[:platforms] = body.scan(/(\w+) System Requirements/).flatten
    if details[:platforms].empty?
      details[:platforms] << "PC"
    end
    
    #TODO, grab screenshots
    
    logger.info "#{details}"
    
    details
  end
end