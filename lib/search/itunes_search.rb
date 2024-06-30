# docs: http://www.apple.com/itunes/affiliates/resources/documentation/itunes-store-web-service-search-api.html#searching
# example: http://itunes.apple.com/search?term=angry+birds&media=software

class Search::ItunesSearch
  include HTTParty
  base_uri 'itunes.apple.com'
  
  def self.for(query, options = {})
    Rails.logger.info "doing itunes search for #{query}, #{options.inspect}"
    response = get('/search',
      query: {
        term: query,
        media: 'software',
        limit: options[:limit] || 20})
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
      results = self.for(term, limit: 200)
      Rails.logger.info "did search for #{term} - got #{results.size} results"
      sleep 1
    end
  end

  def self.parse_item(result)
    #TODO
    #screenshot_urls = result["screenshotUrls"]
    
    release_date =
      begin
        Date.parse(result["releaseDate"])
      rescue ArgumentError
        nil
      end
    track_id = result["trackId"]

    
    new_itunes_port = ItunesPort.new(
      price: (result['price'].to_f * 100).to_i,
      url: result["trackViewUrl"],
      track_id: track_id,
      small_image_url: result["artworkUrl60"],
      medium_image_url: result["artworkUrl100"],
      large_image_url: result["artworkUrl512"],
      version: result["version"],
      description: result["description"])
    title = result["trackName"]

    old_itunes_port = ItunesPort.find_by_track_id(track_id)
    if old_itunes_port

      if !old_itunes_port.port
        Rails.logger.info "deleting orphaned itunes_port #{old_itunes_port.id}"
        old_itunes_port.destroy
      else
        old_itunes_port.update!(
          price: new_itunes_port.price,
          url: new_itunes_port.url,
          small_image_url: new_itunes_port.small_image_url,
          medium_image_url: new_itunes_port.medium_image_url,
          large_image_url: new_itunes_port.large_image_url,
          version: new_itunes_port.version,
          description: new_itunes_port.description)  

        old_itunes_port.port.update!(
          released_at: release_date,
          released_at_accuracy: "day",
          title: title)

        Rails.logger.info "Found existing itunes_port #{old_itunes_port.id}, updated"
        return old_itunes_port.port.game
      end
    end

    platform = Platform.get_by_name("iOS")
    if !platform
      raise "no ios platform"
    end

    existing_port = Port.where(title: title, platform_id: platform.id).first
    if existing_port
      if existing_port.additional_data.is_a?(IgdbGame) || existing_port.additional_data.is_a?(GiantBombPort)
        Rails.logger.info "Found existing port #{existing_port.id}, leaving alone"
        return existing_port.game
      end

      existing_port.update!(
        released_at: release_date,
        released_at_accuracy: "day",
        title: title,
        additional_data: new_itunes_port)
      return existing_port.game
    end

    game = Game.new(title: title)

    port = game.ports.new(
      title: title,
      released_at: release_date,
      released_at_accuracy: "day",
      additional_data: new_itunes_port,
      platform: platform)
    
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
    
    genres.each do |genre|
      game.add_genre genre
    end

    game.set_best_port

    
    game
  end
end