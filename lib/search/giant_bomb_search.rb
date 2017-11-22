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
    total_items = parsed_response["number_of_total_results"]
    page_size = parsed_response["limit"]
    current_page = (offset / page_size) + 1


    results = parsed_response["results"].collect {|r| parse_item(r)}
    results.compact!
    
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

    if !result['platforms']
      return nil
    end



    old_giant_bomb_port =
      GiantBombPort.where(giant_bomb_id: new_giant_bomb_port.giant_bomb_id).first
    if old_giant_bomb_port
      update_existing_records(old_giant_bomb_port, new_giant_bomb_port, result)
      return old_giant_bomb_port.port.game
    end

    title = result['name']

    game = Game.new(title: title)
    game.initially_released_at, game.initially_released_at_accuracy =
      get_release_date(result)

    new_ports = result['platforms'].collect do |platform_data|
      platform_name = platform_data["name"]
      platform = Platform.get_by_name(platform_name) ||
        Platform.new(:name => platform_name)

      Port.new(
        :game => game,
        :title => title,
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

  def self.get_release_date(result)
    original_release_date_string = result["original_release_date"]
    if original_release_date_string
      return DateTime.parse(original_release_date_string).to_date, "day"
    end
    expected_release_year = result["expected_release_year"]
    unless expected_release_year
      return nil, nil
    end
    expected_release_date_accuracy = "year"

    expected_release_month = result["expected_release_month"]
    if expected_release_month
      expected_release_date_accuracy = "month"
    end
    expected_release_day = result["expected_release_day"]
    if expected_release_day
      expected_release_date_accuracy = "day"
    end
    expected_release_date = Date.new(
      expected_release_year,
      expected_release_month || 1,
      expected_release_day || 1)
    return expected_release_date, expected_release_date_accuracy
  end

  def self.update_existing_records(old_giant_bomb_port, new_giant_bomb_port, result)
    Rails.logger.info "found existing port #{old_giant_bomb_port.id}, updating"

    title = result['name']

    old_giant_bomb_port.update!(
      url: new_giant_bomb_port.url,
      image_id: new_giant_bomb_port.image_id,
      description: new_giant_bomb_port.description)
    
    game = old_giant_bomb_port.port.game
    game.initially_released_at, game.initially_released_at_accuracy =
      get_release_date(result)
    game.save!

    result['platforms'].each do |platform_data|
      platform_name = platform_data["name"]
      platform = Platform.get_by_name(platform_name) ||
        Platform.new(:name => platform_name)

      existing_port = platform.id? && game.ports.where(platform_id: platform.id).first
      
      if existing_port
        existing_port.update!(title: title, additional_data: old_giant_bomb_port)
      else
        Port.create!(
          :game => game,
          :title => title,
          :additional_data => old_giant_bomb_port,
          :platform => platform)
      end
    end

    true
  end
end

