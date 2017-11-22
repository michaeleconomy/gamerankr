class Tasks::CountFixer
  def self.fix_port_rankings_counts

  	fix_non_zero_port_rankings_counts + fix_zero_port_rankings_counts
  end

  def self.fix_non_zero_port_rankings_counts
  	off_ports = Ranking.includes(:port).
  	  group("port_id, rankings_count").
  	  having("rankings_count != count(1)").
  	  pluck("port_id, rankings_count, count(1)")
  	off_ports.each do |port_id, rankings_count, correct_count|
  		Port.where(id: port_id).update_all(rankings_count: correct_count)
  	end
  	off_ports.size
  end

  def self.fix_zero_port_rankings_counts
  	port_ids = Port.where("id not in(select distinct(port_id) from rankings) and rankings_count != 0").pluck(:id)
  	Port.where(id: port_ids).update_all(rankings_count: 0)
  end
end