class Tasks::Merger

	#NOTE: this doesn't work for tombraider PC (there are two games with the same title, so it will delete one of the versions)
	def self.merge_duplicate_ports_by_title_and_platform
		dups = Port.from("ports a, ports b").
			where("a.platform_id = b.platform_id and " +
				"a.title = b.title and " +
				"a.additional_data_type = 'GiantBombPort' and "+
				"b.additional_data_type != 'GiantBombPort'").
			pluck("a.id, b.id")
		dups.each do |ids|
			ports = Port.where(id: ids).all
			if ports.size != 2
				next
			end
			begin
				merge_ports(ports)
			rescue ActiveRecord::RecordInvalid => e
				puts "dups #{ports.collect(&:to_param).join(", ")} couldn't be joined: #{e}\n#{e.backtrace.join("\n")}"
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
			merge_ports([p1, p2])
		end
	end

	def self.merge_ports(ports)
		port_to_remove = choose_which_to_get_rid_of(ports)

		remaining_ports = ports - [port_to_remove]

		port_to_migrate_to = remaining_ports.first
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
			if !p.additional_data.is_a?(GiantBombPort)
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