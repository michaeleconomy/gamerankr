class Tasks::Merger

	#NOTE: this doesn't work for tombraider PC (there are two games with the same title, so it will delete one of the versions)
	def self.merge_duplicate_ports_by_title_and_platform(test_run = true)
		dups = Port.from("ports a, ports b, games g1, games g2").
			where("a.game_id = g1.id and b.game_id = g2.id and " +
				"a.platform_id = b.platform_id and " +
				"a.title = b.title and " +
				"a.additional_data_type = 'IgdbGame' and "+
				"b.additional_data_type != 'IgdbGame' and "+
				"extract(year from g1.initially_released_at) = extract(year from g2.initially_released_at)").
			pluck("a.id, b.id")
		dups.each do |ids|
			ports = Port.where(id: ids).all
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

	def self.merge_duplicate_ports
		ids = Port.from("ports a, ports b").
			where("a.game_id = b.game_id and a.platform_id = b.platform_id and a.id > b.id").
			pluck("a.id")
		ids.each do |id|
			p1 = Port.where(id: id).first
			next unless p1
			p2 = Port.where("game_id = ? and platform_id = ? and id != ?",
				p1.game_id, p1.platform_id, p1.id).first
			next unless p2
			merge_ports([p1, p2], false)
		end
	end

	def self.merge_ports(ports, test_run)
		port_to_remove = choose_which_to_get_rid_of(ports)

		remaining_ports = ports - [port_to_remove]

		port_to_migrate_to = remaining_ports.first

		if test_run
			Rails.logger.info "would merge #{port_to_remove.to_param}(#{port_to_remove.rankings_count} #{port_to_remove.additional_data_type}) into " +
				"#{port_to_migrate_to.to_param}(#{port_to_migrate_to.rankings_count} #{port_to_migrate_to.additional_data_type}) "
			return
		end
		port_to_remove.rankings.each do |r|
			r.port_id = port_to_migrate_to.id
			r.game_id = port_to_migrate_to.game_id
			r.save! #not ok with failure!
		end

		port_to_remove.destroy!
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