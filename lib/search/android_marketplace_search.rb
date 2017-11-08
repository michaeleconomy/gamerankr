#BROKEN!!!!
#TODO
#new url:
#https://play.google.com/store/search?q=angry%20birds&c=apps

class Search::AndroidMarketplaceSearch
  
  include HTTParty
  base_uri 'https://play.google.com'
  
  BLOCKED_GENRES = ["Widgets", "Live Wallpaper", "Books & Reference", "Business",
    "Comics", "Communication", "Education", "Entertainment", "Finance",
    "Health & Fitness", "Libraries & Demo", "Lifestyle", "Media & Video",
    "Medical", "Music & Audio", "News & Magazines", "Personalization",
    "Photography", "Productivity", "Shopping", "Social", "Sports", "Tools",
    "Transportation", "Travel & Local", "Weather"]
  
  def self.for(query, options = {})
    Rails.logger.info "doing Android search for #{query}, #{options.inspect}"
    
    response = get('/store/search',
      :query => {
        :q => query,
        :so => 1,
        :c => 'apps'
        # sort=0 # sort by poularity #TODO
        })
    parsed_response = Nokogiri::HTML(response.body)
    parsed_response.css("li.search-results-item").collect do |result|
      parse_item(result)
    end.compact
  end
  
  def self.parse_item(result)
    title_element = result.css(".title").first
    url = title_element.attributes["href"].value
    url =~ /id=([\.\w]+)/
    am_id = $1
    title = title_element.content
    image_element = result.css("img").first
    image_url = image_element.attributes["src"].value
    company = result.css(".attribution").first.content
    genre = result.css(".category").first.content
    description = result.css(".description").first.content
    price = nil
    if price_container = result.css(".buy-button-price").first
      price = price_container.content.gsub(/[^\w]/, "").to_i
    end
    
    new_am_port = AndroidMarketplacePort.new(
      :am_id => am_id,
      :url => url,
      :price => price,
      :image_url => image_url,
      :description => description)
      
    old_am_port = AndroidMarketplacePort.find_by_am_id(new_am_port.am_id)
    if old_am_port
      Rails.logger.info "found existing port #{old_am_port.id}, updating"
      old_am_port.url = new_am_port.url
      old_am_port.price = new_am_port.price
      old_am_port.image_url = new_am_port.image_url
      old_am_port.description = new_am_port.description
      
      old_am_port.save!
      return old_am_port.port
    end
    
    if title =~ /walkthrough|cheats/
      Rails.logger.info "not importing game with title: #{title}"
      return nil
    end
    
    if BLOCKED_GENRES.include?(genre)
      Rails.logger.info "not importing game of genre: #{genre}"
      return nil
    end
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
      :additional_data => new_am_port,
      :platform => Platform.get_by_name("Android"))
    
    game = new_port.set_game
    
    new_port.add_publisher(company)
    
    game.add_genre genre
    
    new_port.save!
    
    new_port
  end
end