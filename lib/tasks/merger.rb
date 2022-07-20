class Tasks::Merger

  def self.merge_duplicate_ports_by_title_and_platform(test_run = true)
    dups = Port.from("ports a, ports b, games g1, games g2").
      where("a.game_id = g1.id and b.game_id = g2.id and " +
        "a.platform_id = b.platform_id and " +
        "regexp_replace(lower(unaccent(a.title)), '[^\\w\\d]', '', 'g') = regexp_replace(lower(unaccent(b.title)), '[^\\w\\d]', '', 'g') and " +
        "a.additional_data_type = 'IgdbGame' and "+
        "(b.additional_data_type != 'IgdbGame' or b.additional_data_type is null) and "+
        "extract(year from g1.initially_released_at) = extract(year from g2.initially_released_at)").
      order("b.rankings_count").
      pluck("a.id, b.id")
    dups.each do |ids|
      ports = Port.find(ids).to_a
      if ports.size != 2
        next
      end
      begin
        merge_ports(ports, test_run)
      rescue ActiveRecord::RecordInvalid => e
        Rails.logger.info "dups #{ports.collect(&:game_id).join(", ")} couldn't be joined"
      end

    end
    dups.size
  end

  def self.merge_duplicate_ports_on_the_same_game(test_run = true)
    dups = Port.from("ports a, ports b").
      where("a.game_id = b.game_id and " +
        "a.platform_id = b.platform_id and " +
        "a.id > b.id").
      order("b.rankings_count").
      pluck("a.id, b.id")
    dups.each do |ids|
      ports = Port.find(ids).to_a
      if ports.size != 2
        next
      end
      begin
        merge_ports(ports, test_run)
      rescue ActiveRecord::RecordInvalid => e
        Rails.logger.info "dups #{ports.collect(&:game_id).join(", ")} couldn't be joined"
      end

    end
    dups.size
  end

  def self.merge_ports(ports, test_run)
    port_to_keep = choose_which_to_keep(ports)

    remaining_ports = ports - [port_to_keep]

    if test_run
      Rails.logger.info "would merge  #{remaining_ports.map(&:to_param).to_sentence} " +
        "into #{port_to_keep.to_param}"
      return
    end
    remaining_ports.each do |port|
      port.rankings.each do |r|
        r.port_id = port_to_keep.id
        r.game_id = port_to_keep.game_id
        r.save! #not ok with failure!
      end
      port.destroy!
    end
    port_to_keep.game.set_best_port
    true
  end

  def self.merge_games(games)

    all_ports = games.collect(&:ports).flatten
    all_ports.group_by(&:platform_id).each do |platform_id, ps|
      next if ps.size == 1
      merge_ports(ps)
    end

    games.each do |game|
      if game.rankings.count == 0
        game.destroy
      end
    end

    true
  end

  private
  
  def self.choose_which_to_keep(ports)

    ports.each do |p|
      if p.additional_data.is_a?(IgdbGame)
        return p
      end
    end

    ports.each do |p|
      if p.additional_data.is_a?(ItunesPort)
        return p
      end
    end


    ports.each do |p|
      if p.additional_data.is_a?(GiantBombPort)
        return p
      end
    end


    ports.last
  end

  def self.choose_which_to_get_rid_of(ports)
    ports.each do |p|
      if !p.additional_data
        return p
      end
    end
    ports.each do |p|
      if p.additional_data.is_a?(SteamPort)
        return p
      end
    end

    ports.each do |p|
      if p.additional_data.is_a?(AmazonPort)
        return p
      end
    end

    ports.each do |p|
      if p.additional_data.is_a?(AndroidMarketplacePort)
        return p
      end
    end

    ports.each do |p|
      if !p.additional_data.is_a?(IgdbGame)
        return p
      end
    end

    ports.each do |p|
      if p.rankings.count == 0
        return p
      end
    end

    ports.last
  end
end