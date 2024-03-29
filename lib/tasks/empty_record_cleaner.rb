class Tasks::EmptyRecordCleaner

  def self.remove_ports_lacking_additional_data
    ports = Port.where("additional_data_type = 'GiantBombPort' and additional_data_id not in (select id from giant_bomb_ports)").all
    ports.collect(&:id)
    #TODO - add other types
  end

  def self.remove_amazon_ports_without_rankings
    Tasks::CountFixer.fix_port_rankings_counts
    ports = Port.where("additional_data_type = 'AmazonPort' and rankings_count=0").all
    ports.each(&:destroy)

    ports.size
  end


  def self.remove_steam_ports_without_rankings
    Tasks::CountFixer.fix_port_rankings_counts
    ports = Port.where("additional_data_type = 'SteamPort' and rankings_count=0").all
    ports.each(&:destroy)

    ports.size
  end


  def self.remove_android_ports_without_rankings
    Tasks::CountFixer.fix_port_rankings_counts
    ports = Port.where("additional_data_type = 'AndroidMarketplacePort' and rankings_count=0").all
    ports.each(&:destroy)

    ports.size
  end

  def self.remove_itunes_ports_without_rankings
    Tasks::CountFixer.fix_port_rankings_counts
    ports = Port.where("additional_data_type = 'ItunesPort' and rankings_count=0").all
    ports.each(&:destroy)

    ports.size
  end
end