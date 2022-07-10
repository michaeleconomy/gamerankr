class Search::GiantBombSearch
  
  include HTTParty
  base_uri 'https://www.giantbomb.com/'

  FIELDS_LIST = "site_detail_url,deck,id,image,platforms," +
    "expected_release_day,expected_release_month,expected_release_year," +
    "expected_release_quarter,name,original_release_date"

  def self.for(query, options = {})
    page = (options[:page] || 1).to_i
    Rails.logger.info "doing giantbomb search for #{query}, #{options.inspect}"

    response = get('/api/search/',
      :query => {
        :query => query,
        :resources => "game",
        :field_list => FIELDS_LIST,
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

  def self.crawl_games_api(offset = 0)
    loop do
      response = get('/api/games/',
        :query => {
          :field_list => FIELDS_LIST,
          :format => 'json',
          :offset => offset,
          :api_key => Secret['giant_bomb_api_key']
          })
      offset += 100
      puts response.body
      results = parsed_response["results"].collect {|r| parse_item(r)}
      puts "[#{Time.now.strftime("%m/%d/%Y %H:%M.%L")}] fetched #{results.size} results, offset: #{offset}, last_item: #{results.last.to_param}"
      if results.empty?
        puts "no results, closing"
        break
      end
      sleep 30
    end
  end

  def self.crawl_platforms_api(offset = 0)
    loop do
      response = get('/api/platforms/',
        :query => {
          :format => 'json',
          :offset => offset,
          :api_key => Secret['giant_bomb_api_key']
          })
      offset += 100
      parsed_response = JSON.parse(response.body)
      puts response.body
      results = parsed_response["results"].collect {|r| parse_platform(r)}
      puts "fetched #{results.size} results, offset: #{offset}, last_item: #{results.last.to_param}"
      if results.empty?
        break
      end
      sleep 60
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
    
    game.set_best_port
    
    game
  end

  def self.get_image_code(result)
    if (result['image'] &&
        result['image']['icon_url'] &&
        result['image']['icon_url'].match("square_avatar/(.*)"))
      result['image']['icon_url'].match("square_avatar/(.*)")[1]
    end
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

    existing_ports = game.ports.to_a
    validated_existing_ports = []

    result['platforms'].each do |platform_data|
      platform_name = platform_data["name"]
      platform = Platform.get_by_name(platform_name) ||
        Platform.new(:name => platform_name)

      existing_port = nil

      if platform.id?
        i = existing_ports.index do |port|
          port.platform_id == platform.id &&
            port.additional_data && 
            port.additional_data.is_a?(GiantBombPort)
        end
        if i
          existing_port = existing_ports[i]
          validated_existing_ports << existing_port
          existing_ports.delete_at(i)
        end
      end
    
      if existing_port
        existing_port.update!(
          title: title,
          additional_data: old_giant_bomb_port)
      else
        Port.create!(
          :game => game,
          :title => title,
          :additional_data => old_giant_bomb_port,
          :platform => platform)
      end
    end

    # for the remaining ports - that were not found on giantbomb
    existing_ports.each do |port|
      if !port.rankings.exists?
        port.destroy!
      else
        existing_giant_bomb_sourced_port_index = validated_existing_ports.index do |p|
          p.platform_id == port.platform_id
        end

        if existing_giant_bomb_sourced_port_index
          existing_giant_bomb_sourced_port =
            validated_existing_ports[existing_giant_bomb_sourced_port_index]
          port.rankings.update_all(port_id: existing_giant_bomb_sourced_port.id)
          existing_giant_bomb_sourced_port.update(
            rankings_count: existing_giant_bomb_sourced_port.rankings.count)
          port.destroy!
        else
          port.game = Game.new
        end
      end
    end

    true
  end

  def self.parse_platform(result)
    giant_bomb_id = result["id"]
    giant_bomb_platform = GiantBombPlatform.find_or_initialize_by(giant_bomb_id: giant_bomb_id)
    giant_bomb_platform.url = result["site_detail_url"]
    giant_bomb_platform.image_id = get_image_code(result)
    giant_bomb_platform.install_base = result["install_base"]
    giant_bomb_platform.original_price = result["original_price"] && result["original_price"].to_i

    platform_name = result["name"]
    aliases = []
    if result["aliases"]
      aliases += result["aliases"].gsub("\r", "").split("\n")
    end
    if result["abbreviation"]
      aliases << result["abbreviation"]
    end
    aliases.uniq!
    if platform_name == "Nintendo Entertainment System" #hack to ignore this dulicate
      aliases.delete "FDS"
    end
    if platform_name != "PlayStation Network (PS3)" #hack to ignore this dulicate
      aliases.delete "PSN"
    end
    if platform_name != "Neo Geo Pocket" #hack to ignore this dulicate
      aliases.delete "NGP"
    end
    aliases.delete platform_name
    platform = get_platform(giant_bomb_platform, platform_name, aliases)


    platform.description = result["deck"]
    if result["release_date"]
      platform.released_at = DateTime.parse(result["release_date"]).to_date
    end

    aliases.each do |a|
      platform.platform_aliases.find_or_initialize_by(name: a)
    end

    if result["company"]
      platform.manufacturer = Manufacturer.find_or_initialize_by(name: result["company"]["name"])
    end
    platform.save!
    giant_bomb_platform.save!

    platform
  end


  def self.get_platform(giant_bomb_platform, platform_name, aliases)
    if giant_bomb_platform.id #if it already existed
      if !giant_bomb_platform.platform.name == platform_name
        raise "existing platform name: '#{giant_bomb_platform.platform.name}' didn't match new name: '#{platform_name}'"
      end
      return giant_bomb_platform.platform
    end

    platform = Platform.get_by_name(platform_name)
    aliases.each do |a|
      platform ||= Platform.get_by_name(a)
    end
    platform ||= Platform.new(name: platform_name)
    giant_bomb_platform.platform = platform
    if platform.name != platform_name
      old_name = platform.name
      platform.name = platform_name
      alias_to_destroy = platform.platform_aliases.where(name: platform_name).first
      if alias_to_destroy
        alias_to_destroy.destroy
      end
      if !aliases.index(old_name)
        platform.platform_aliases.new(name: old_name)
      end
    end
    platform
  end
end

