class Tasks::BestPortSetter
	def self.go
    Rails.logger.info "getting existing best port data"
    game_data = Game.pluck(:id, :best_port_id)

    Rails.logger.info "hashing existing best port data"
    existing_best_ports = {}
    game_data.each do |id, best_port_id|
      existing_best_ports[id] = best_port_id
    end


    Rails.logger.info "getting new best port data"
    port_data = Port.pluck(:game_id, :id, :rankings_count)
    
    Rails.logger.info "organizing new best port data"
    new_best_ports = Hash.new{|hash, key| hash[key] = [0,-1]}
    port_data.each do |game_id, port_id, count|
      existing_new_port_id, existing_count = new_best_ports[game_id]
      if count > existing_count
        new_best_ports[game_id] = [port_id, count]
      end
    end
    num_updated = 0
    Rails.logger.info "writing new best ports"
    new_best_ports.each do |game_id, port_info|
      port_id, count = port_info
      if existing_best_ports[game_id] != port_id
        Game.where(id: game_id).update_all(best_port_id: port_id)
        num_updated += 1
      end
    end
    num_updated
  end
end