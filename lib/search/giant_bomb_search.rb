class Search::GiantBombSearch
  
  include HTTParty
  base_uri 'https://www.giantbomb.com/'

  def self.for(query, options = {})
    page = (options[:page] || 1).to_i
    Rails.logger.info "doing giantbomb search for #{query}, #{options.inspect}"

  response = get('/api/search/',
      :query => {
        :query => query,
        :resources => "game",
        :field_list => "site_detail_url,deck,id,image,platforms," + "
          expected_release_day,expected_release_month,expected_release_year," +
          "expected_release_quarter,name,original_release_date",
        :format => 'json',
        :page => page,
        :api_key => Secret['giant_bomb_api_key']
        })

    Rails.logger.info "response.body: #{response.body}"

    # pagination stuff
    parsed_response = JSON.parse(response.body)
    offset = parsed_response["offset"]
    total_items = parsed_response["number_of_page_results"]
    page_size = parsed_response["limit"]
    current_page = (offset / page_size) + 1


    results = parsed_response["results"].collect {|r| parse_item(r)}
    
    WillPaginate::Collection.create(current_page, page_size, total_items) do |pager|
      pager.replace(results)
    end
  end

  private

  def self.parse_item(result)
    new_giant_bomb_port = GiantBombPort.new(
      :url => result["site_detail_url"],
      :giant_bomb_id => result["id"],
      :image_id => get_image_code(result),
      :description => result["deck"])

    title = result['name']

    old_giant_bomb_port =
      GiantBombPort.where(giant_bomb_id: new_giant_bomb_port.giant_bomb_id).
        includes(:port => :game).first
    if old_giant_bomb_port
      Rails.logger.info "found existing port #{old_giant_bomb_port.id}, updating"
      old_giant_bomb_port.url = new_giant_bomb_port.url
      old_giant_bomb_port.image_id = new_giant_bomb_port.image_id
      old_giant_bomb_port.description = new_giant_bomb_port.description
      
      old_giant_bomb_port.save!
      return old_giant_bomb_port.port
    end

    game = Game.get_by_title(title)
    new_ports = result['platforms'].collect do |platform_data|
      platform_name = platform_data["name"]
      platform = Platform.get_by_name(platform_name) ||
        Platform.new(:name => platform_name)

      Port.new(
        :game => game,
        :title => title,
      # :released_at => released_at,
      # :released_at_accuracy => released_at_accuracy,
        :additional_data => new_giant_bomb_port,
        :platform => platform)
    end
    
    # new_port.add_publisher(company)
    
    # game.add_genre genre
    
    new_ports.each(&:save!)
    
    game
  end

  def self.get_image_code(result)
    result['image']['icon_url'].match("square_avatar/(.*)")[1]
  end

end

