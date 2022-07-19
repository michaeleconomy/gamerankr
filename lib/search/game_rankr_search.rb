class Search::GameRankrSearch
  def self.for(query, options = {})
    page = (options[:page] || 1).to_i
    games = association_for(query).
    	paginate(page: page)
    
    WillPaginate::Collection.create(page, games.per_page, [games.total_entries, games.per_page * 10].min) do |pager|
      pager.replace(games.filter{|g| g.best_port})
    end
  end

  def self.association_for(query)
    Game.
      default_preload.
      search(query).
      order("rankings_count desc, id desc")
  end
end