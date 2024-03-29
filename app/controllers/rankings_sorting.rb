module RankingsSorting


  #Note: this logic has largely been moved to application_controller.add_sort
  #this code should be removed
  
  COLUMNS = ActiveSupport::OrderedHash.new
  COLUMNS["Title"] = "lower(ports.title)"
  COLUMNS["Platform"] = "platforms.name"
  COLUMNS["Date Added"] = "rankings.created_at"
  COLUMNS["Avg"] = nil
  COLUMNS["Times Added"] = "games.rankings_count"
  COLUMNS["My Shelves"] = nil
  COLUMNS["My Rating"] = "rankings.ranking"
  COLUMNS["My Review"] = nil
  
  def get_sort
    @sort = params[:sort]
    @columns = COLUMNS.keys
    @sort_order = " desc" if params[:order] == "d"
    if !COLUMNS[@sort]
      @sort = "Date Added"
      @sort_order = " desc"
    end
  end
  
  def get_view
    @views = %w(list covers sideways)
    @view = @views.include?(params[:view]) ? params[:view] : @views.first
  end
end