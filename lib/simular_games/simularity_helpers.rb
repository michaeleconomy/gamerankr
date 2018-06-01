module SimularGames::SimularityHelpers
  
  def rankings_count(game_id)
    if !@rankings_counts
      fetch_rankings_counts
    end
    @rankings_counts[game_id]
  end

  def average_rating(game_id)
    unless @average_ratings
      load_average_ratings
    end
    @average_ratings[game_id] || 0
  end

  def load_average_ratings
    Rails.logger.info "grabbing aberage ratings from db"
    @average_ratings = {}
    raw_ratings =
      Ranking.where("ranking is not null").
      group(:game_id).
      pluck(:game_id, Arel.sql("avg(ranking)"))
    Rails.logger.info "hashing average ratings"
    raw_ratings.each do |id, avg|
      @average_ratings[id] = avg
    end
  end

  def fetch_rankings_counts
    Rails.logger.info "grabbing rankings_counts from db"
    rankings_counts_raw = Game.pluck(:id, :rankings_count)
    Rails.logger.info "hashing rankings count"
    @rankings_counts = {}
    rankings_counts_raw.each do |id, count|
      @rankings_counts[id] = count
    end
    @rankings_counts
  end
end