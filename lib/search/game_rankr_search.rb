class Search::GameRankrSearch
  def self.for(query, options = {})
    page = (options[:page] || 1).to_i
    games = Game.includes(:ports).where("lower(title) like ?", "%#{query}%").paginate(:page => page)
    
    
    WillPaginate::Collection.create(page, games.per_page, [games.total_entries, 100].min) do |pager|
      pager.replace(games.collect{|g| g.ports.first})
    end
  end
end