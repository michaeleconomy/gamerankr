module RankingsSorting
  
  COLUMNS = ActiveSupport::OrderedHash.new
  COLUMNS["Title"] = "ports.title"
  COLUMNS["Platform"] = "platforms.name"
  COLUMNS["Date Added"] = "rankings.created_at"
  COLUMNS["Avg"] = nil
  COLUMNS["Rankings"] = "games.rankings_count"
  COLUMNS["My Shelves"] = nil
  COLUMNS["My Rating"] = "rankings.ranking"
  COLUMNS["My Review"] = "rankings.review"
  
  def get_sort
    @sort = params[:sort]
    @columns = COLUMNS.keys
    @sort = @columns.first unless COLUMNS[@sort]
    @sort_order = " desc" if params[:order] == "d"
  end
  
  def get_view
    @views = %w(list covers sideways)
    @view = @views.include?(params[:view]) ? params[:view] : @views.first
  end
end