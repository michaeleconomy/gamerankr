class IgdbClient
  
  FIELDS_LIST = "name,cover.image_id,first_release_date,summary," +
    "category,status," +
    "alternative_names.name," +
    "collection.name," +
    "parent_game," +
    "franchises.name,genres.name,"+
    "involved_companies.developer,involved_companies.publisher,involved_companies.company.name," +
    "release_dates.date,release_dates.category,release_dates.platform.name"

  def self.crawl_games(offset = 0)
    loop do
      check_auth
      http = Net::HTTP.new('api.igdb.com',443)
      http.use_ssl = true
      request = Net::HTTP::Post.new(URI('https://api.igdb.com/v4/games'),
        'Client-ID': Secret["twitch_client_id"],
        'Authorization': "Bearer " + Secret["igdb_token"])

      request.body = "fields #{FIELDS_LIST};limit: 500;offset #{offset};"
      response = http.request(request)

      parsed_response = JSON.parse(response.body)
      Rails.logger.debug "response: #{JSON.pretty_generate(parsed_response)}"
      offset += 500
      last = nil
      parsed_response.each do |r|
        begin
          last = parse_item(r)
        rescue StandardError => e
          Rails.logger.error "error parsing:\n#{r}\n\n#{e}"
          raise e
        end
      end
      puts "[#{Time.now.strftime("%m/%d/%Y %H:%M.%L")}] fetched #{parsed_response.size} results," +
        " offset: #{offset}, last_item: #{last.to_param}"
      Rails.logger.info "[#{Time.now.strftime("%m/%d/%Y %H:%M.%L")}] fetched #{parsed_response.size} results," +
        " offset: #{offset}, last_item: #{last.to_param}"
      if parsed_response.empty?
        puts "no results, closing"
        break
      end
      sleep 0.5
    end
  end


  def self.game(id)
    check_auth
    http = Net::HTTP.new('api.igdb.com',443)
    http.use_ssl = true
    request = Net::HTTP::Post.new(URI('https://api.igdb.com/v4/games'),
      'Client-ID': Secret["twitch_client_id"],
      'Authorization': "Bearer " + Secret["igdb_token"])

    request.body = "fields #{FIELDS_LIST};where id = #{id};"
    response = http.request(request)

    parsed_response = JSON.parse(response.body)
    Rails.logger.debug "response: #{JSON.pretty_generate(parsed_response)}"
    if parsed_response.size == 1
      return parse_item(parsed_response[0])
    end
    if parsed_response.size > 1
      puts "multiple games found?!"
    else
      puts "no game found"
    end
    nil
  end


  private

  def self.check_auth
    return if !token_expired?
    authenticate
  end

  def self.token_expired?
    !token_expiration || token_expiration <= Time.now
  end

  def self.token_expiration
    return @expires_at if @expires_at
    expiration_s = Secret["igdb_token_expires_at"]
    if !expiration_s
      return nil
    end
    @expires_at = Time.at(expiration_s.to_i)
  end

  def self.authenticate
    Rails.logger.info "igdb token renewing"
    uri = URI("https://id.twitch.tv/oauth2/token")
    response = Net::HTTP.post_form uri,
      client_id: Secret["twitch_client_id"],
      client_secret: Secret["twitch_client_secret"],
      grant_type: "client_credentials"
    if response.code != "200"
      raise "IGDB Auth Failure: " + response.body
    end
    body_json = JSON.parse(response.body)
    Secret["igdb_token"] = body_json["access_token"]

    @expires_at = (body_json["expires_in"] - 1000).seconds.from_now
    Secret["igdb_token_expires_at"] = @expires_at.to_i
    Rails.logger.info "igdb token renewed"
  end

  def self.parse_item(result)
    if !result["release_dates"].is_a?(Array)
      return nil
    end

    if result["status"] && (result["status"] == 6 || result["status"] == 7)
      return nil
    end

    igdb_game = IgdbGame.find_or_initialize_by(igdb_id: result["id"])
    igdb_game.attributes = {
      cover_image_id: result["cover"] && result["cover"]["image_id"],
      description: result["summary"]
    }

    game = nil
    if igdb_game.id?
      game = igdb_game.ports.first && igdb_game.ports.first.game
    end

    if !game
      game = Game.new
    end
    existing_ports = game.ports
    new_ports = []
    left_overs = Array.new existing_ports

    releases_by_platform = result["release_dates"].
      filter{|r| r['platform']}.
      group_by{|r| r["platform"] && r["platform"]["name"]}
    if releases_by_platform.empty?
      return
    end
    game.title = result['name']

    releases_by_platform.each do |platform_name, releases|
      earliest = releases.filter{|r| r["date"]}.min{|r| r["date"]}
      platform = Platform.get_by_name(platform_name) ||
        Platform.create!(name: platform_name)
      if new_ports.find{|e| e.platform == platform}
        next
      end
      port = existing_ports.find{|e| e.platform == platform}
      if port
        left_overs.delete(port)
      else
        port = game.ports.new(platform: platform)
      end
      port.additional_data = igdb_game

      port.title = result['name']
      if earliest && earliest['date']
        port.released_at = Time.at earliest['date']
        port.released_at_accuracy =
          case earliest['category']
          when 0
            "day"
          when 1
            "month"
          else
            "year"
          end

        if !game.initially_released_at || game.initially_released_at > port.released_at
          game.initially_released_at = port.released_at
          game.initially_released_at_accuracy = port.released_at_accuracy
        end
      end
      new_ports << port
    end

    left_overs.each do |port|
      if !port.rankings.any?
        port.destroy!
      else
        Rails.logger.error "port not found, but not delete bc rankings: #{port.id} #{port.title} #{port.platform.name}"
      end
    end
    

    if !igdb_game.save
      raise "could not save igdb_game: #{igdb_game.errors.inspect}"
    end
    new_ports.each do |port|
      if !port.save
        raise "could not save port: #{port.errors.inspect}"
      end
    end
    
    game.set_best_port
    if !game.save
      raise "could not save game: #{game.errors.inspect}"
    end


    if result['genres']
      genres = result['genres'].map{|r| r['name']}
      game.set_genres genres
    else
      game.set_genres []
    end

    if result['franchises']
      franchises = result['franchises'].map{|r| r['name']}
      game.set_franchises franchises
    else
      game.set_franchises []
    end

    if result['collection']
      series = result['collection']['name']
      game.set_series [series]
    else
      game.set_series []
    end

    if result["alternative_names"]
      game.set_alternate_names result["alternative_names"].map{|n| n['name']}
    else
      game.set_alternate_names []
    end

    if result["involved_companies"]
      all_companies = result["involved_companies"]
      developers = all_companies.select{|c| c["developer"] == true && c['company'] && c['company']['name'] }.map{|c| c['company']['name']}
      game.set_developers developers

      publishers = all_companies.select{|c| c["publisher"] == true && c['company'] && c['company']['name']}.map{|c| c['company']['name']}
      game.set_publishers publishers
    else
      game.set_publishers []
    end
    
    game
  end

end