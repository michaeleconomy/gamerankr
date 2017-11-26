class Search::GameRankrSearch
  def self.for(query, options = {})
    page = (options[:page] || 1).to_i
    games = Game.
    	includes(:ports).
    	where("unaccent(lower(title)) like unaccent(lower(?))", "%#{query}%").
    	order("rankings_count desc, id desc").
    	paginate(:page => page)
    
    WillPaginate::Collection.create(page, games.per_page, [games.total_entries, games.per_page * 10].min) do |pager|
      pager.replace(games)
    end
  end
end