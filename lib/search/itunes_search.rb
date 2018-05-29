# docs: http://www.apple.com/itunes/affiliates/resources/documentation/itunes-store-web-service-search-api.html#searching
# example: http://itunes.apple.com/search?term=angry+birds&media=software

class Search::ItunesSearch
  include HTTParty
  base_uri 'itunes.apple.com'
  
  def self.for(query, options = {})
    Rails.logger.info "doing itunes search for #{query}, #{options.inspect}"
    response = get('/search',
      :query => {
        :term => query,
        :media => 'software',
        :limit => options[:limit] || 20})
    puts "response.body: #{response.body}"
    json = JSON.parse(response.body)
    results = json["results"]
    results.collect do |result|
      parse_item(result)
    end.compact
  end

  SEARCH_TERMS = %w(game science sci-fi puzzle fun adventure arcade fantasy
    monster boss villian card RPG play playing casual hardcore massively
    multiplayer indie platformer platform fight fighting object objective
    man fps third strategy rogue first person board card cards sport rythym
    music casino race racing car angry simulation word friends stealth trivia
    match awr battle challenge trial trail camp death life action brawl facebook
    valor brave run dash hidden hit goal ball snake animals drive ride crash
    survival zombie)
  
  def self.crawl
    SEARCH_TERMS.each do |term|
      results = self.for(term, :limit => 200)
      Rails.logger.info "did search for #{term} - got #{results.size} results"
      sleep 1
    end
  end

  def self.parse_item(result)
    #TODO
    #screenshot_urls = result["screenshotUrls"]
    
    #TODO
    #devices = result["supportedDevices"]
    
    release_date =
      begin
        Date.parse(result["releaseDate"])
      rescue ArgumentError
        nil
      end
    track_id = result["trackId"]
    
    new_itunes_port = ItunesPort.new(
      :price => (result['price'].to_f * 100).to_i,
      :url => result["trackViewUrl"],
      :track_id => track_id,
      :small_image_url => result["artworkUrl60"],
      :medium_image_url => result["artworkUrl100"],
      :large_image_url => result["artworkUrl512"],
      :version => result["version"],
      :description => result["description"])
    
    platforms = []
    if result["supportedDevices"].index {|device| device =~ /iPad/}
      platforms << "iPad"
    end

    if result["supportedDevices"].index {|device| device =~ /iPhone/}
      platforms << "iPhone"
    end

    title = result["trackName"]

    game = Game.new(title: title)

    new_ports = platforms.collect do |platform|
      Port.new(
        :title => title,
        :released_at => release_date,
        :released_at_accuracy => "day",
        :additional_data => new_itunes_port,
        :platform => Platform.get_by_name(platform),
        :game => game)
    end
    
    old_itunes_port = ItunesPort.find_by_track_id(track_id)
    if old_itunes_port
      Rails.logger.info "Found duplicate port #{old_itunes_port.id}, updated"
      old_itunes_port.price = new_itunes_port.price
      old_itunes_port.url = new_itunes_port.url
      old_itunes_port.small_image_url = new_itunes_port.small_image_url
      old_itunes_port.medium_image_url = new_itunes_port.medium_image_url
      old_itunes_port.large_image_url = new_itunes_port.large_image_url
      old_itunes_port.version = new_itunes_port.version
      old_itunes_port.description = new_itunes_port.description
      old_itunes_port.save
      return old_itunes_port.port.game
    end

    new_ports.each do |new_port|
      existing_port = Port.where(title: title, platform_id: new_port.platform_id).first
      if existing_port
        return existing_port.game
      end
    end
    
    genres = result["genres"]
    
    if genres.include?('Reference') ||
      genres.include?("Lifestyle") ||
      genres.include?("Books")
      Rails.logger.info "not adding data for #{title}, because genres were: #{genres.inspect}"
      return nil
    end
      
    unless genres.delete("Games")
      Rails.logger.info "not adding data for #{title}, because genres #{genres.inspect} did not contain 'Game'"
      return nil
    end
    %w(Books Dice Education Entertainment Kids Utilities).each do |blacklist_genre|
      genres.delete blacklist_genre
    end
    
    if title =~ /walkthrough|cheats/i || title =~ /^guide to/i
      Rails.logger.info "not adding data for #{title}, because the title looked like trash"
      return nil
    end

    
    new_ports.each do |new_port|
      publisher = new_port.add_publisher(result["sellerName"])
      publisher.url ||= result["sellerUrl"]
      
      new_port.add_developer(result["artistName"])
      new_port.save!
    end
    
    genres.each do |genre|
      game.add_genre genre
    end
    
    game
  end

  def self.clean_up_images
    ItunesPort.where("large_image_url like ?", "httpss%").each do |p|
      p.large_image_url = p.large_image_url.gsub("httpss", "https").gsub("-ssl-ssl", "-ssl")
      p.small_image_url = p.small_image_url.gsub("httpss", "https").gsub("-ssl-ssl", "-ssl")
      p.medium_image_url = p.medium_image_url.gsub("httpss", "https").gsub("-ssl-ssl", "-ssl")
      p.save!
    end
  end
end