class Tasks::Merger
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
			merge([p1, p2])
		end
	end

	private
  def self.choose_which_to_get_rid_of(ports)
		ports.each do |p|
			if p.additional_data && p.additional_data.is_a?(SteamPort)
				return p
			end
		end

		ports.each do |p|
			if p.additional_data && p.additional_data.is_a?(AmazonPort)
				return p
			end
		end

		ports.each do |p|
			if p.additional_data && p.additional_data.is_a?(AndroidMarketplacePort)
				return p
			end
		end


		ports.each do |p|
			if p.rankings.count == 0
				return p
			end
		end

		p.last
  end

	def self.merge(ports)
		port_to_remove = choose_which_to_get_rid_of(ports)

		remaining_ports = ports - [port_to_remove]

		port_to_migrate_to = remaining_ports.first
		port_to_remove.rankings.each do |r|
			r.port_id = port_to_migrate_to.id
			r.save! #not ok with failure!
		end
		port_to_remove.publisher_games.each do |pg|
			pg.port_id = port_to_migrate_to.id
			pg.save #ok with failures here
		end

		port_to_remove.developer_games.each do |dg|
			dg.port_id = port_to_migrate_to.id
			dg.save #ok with failures here
		end

		port_to_remove.destroy!
	end
end