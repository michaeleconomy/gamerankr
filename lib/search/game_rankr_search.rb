class Search::GameRankrSearch
  def self.for(query, options = {})
  	lower_case_query = query.downcase
    page = (options[:page] || 1).to_i
    games = Game.
    	includes(:ports).
    	where("lower(title) like ?", "%#{lower_case_query}%").
    	order("rankings_count desc").
    	paginate(:page => page)
    
    WillPaginate::Collection.create(page, games.per_page, [games.total_entries, 100].min) do |pager|
      pager.replace(games)
    end
  end
end