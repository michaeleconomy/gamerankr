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
        :media => 'software'})
    json = JSON.parse(response.body)
    results = json["results"]
    results.collect do |result|
      parse_item(result)
    end.compact
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
    
    new_port = Port.new(
      :title => result["trackName"],
      :released_at => release_date,
      :released_at_accuracy => "day",
      :additional_data => new_itunes_port,
      :platform => Platform.get_by_name("iPhone/iPod"))
    
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
      return old_itunes_port.port
    end
    
    genres = result["genres"]
    
    if genres.include?('Reference') || genres.include?("Lifestyle") || genres.include?("Books")
      Rails.logger.info "not adding data for #{new_port.title}, because genres were: #{genres.inspect}"
      return nil
    end
      
    unless genres.delete("Games")
      Rails.logger.info "not adding data for #{new_port.title}, because genres #{genres.inspect} did not contain 'Game'"
      return nil
    end
    %w(Books Dice Education Entertainment Kids Utilities).each do |blacklist_genre|
      genres.delete blacklist_genre
    end
    
    if new_port.title =~ /walkthrough|cheats/i || new_port.title =~ /^guide to/i
      Rails.logger.info "not adding data for #{new_port.title}, because the title looked like trash"
      return nil
    end
    
    game = new_port.set_game
    
    Rails.logger.info "game: " + new_port.game.inspect
    
    publisher = new_port.add_publisher(result["sellerName"])
    publisher.url ||= result["sellerUrl"]
    
    new_port.add_developer(result["artistName"])
    
    
    new_port.save!
    
    genres.each do |genre|
      game.add_genre genre
    end
    
    new_port
  end
end