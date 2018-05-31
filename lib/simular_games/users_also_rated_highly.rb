class SimularGames::UsersAlsoRatedHighly

  ALGORITHM_ID = 1


  def self.generate
    raw_rankings = get_raw_rankings
    simularity_counts = get_simularity_counts(raw_rankings)
    normalize_by_ranking_count(simularity_counts)

    related_games = limit_to_best(simularity_counts)
    write_to_db(related_games)
    nil
  end

  def self.get_raw_rankings
    Rails.logger.info("grabbing raw rankings from db")
    Ranking.where("ranking is null or ranking in (4, 5)").pluck(:user_id, :game_id, :ranking)
  end

  def self.get_simularity_counts(rankings)
    Rails.logger.info "grouping by user"
    rankings_grouped_by_user = Hash.new{|hash, key| hash[key] = []}
    rankings.each do |user_id, game_id, rating|
      rankings_grouped_by_user[user_id] << [game_id, rating]
    end

    # Rails.logger.info("sorting user rankings")
    # rankings_grouped_by_user.each do |user_id, user_rankings|
    #   user_rankings.sort!
    # end

    Rails.logger.info("counting simularities")
    simularity_counts = Hash.new{|hash, key| hash[key] = Hash.new(0)}
    rankings_grouped_by_user.each do |user_id, user_rankings|
      user_rankings.each do |game_id, rating|
        user_rankings.each do |game_id2, rating_2|
          next if game_id == game_id2
          simularity_counts[game_id][game_id2] += 1.0
        end
      end
    end

    simularity_counts
  end

  def self.limit_to_best(simularity_counts)
    Rails.logger.info "limiting to best"
    simularity_counts.collect do |game_id, simularities|
      simluarities_limited =
        simularities.to_a.shuffle.sort_by{|id, score| -score}.first(10)
      [game_id, simluarities_limited]
    end
  end

  
  def self.normalize_by_ranking_count(simularity_counts)
    rankings_counts = get_rankings_counts

    Rails.logger.info "normalizing by rankings count"
    simularity_counts.each do |game_id, simularities|
      simularities.each do |other_game_id, score|
        simularities[other_game_id] = score / rankings_counts[other_game_id]
      end
    end
  end

  def self.get_rankings_counts
    Rails.logger.info "grabbing rankings_counts from db"
    rankings_counts_raw = Game.pluck(:id, :rankings_count)
    Rails.logger.info "hashing rankings count"
    rankings_counts = {}
    rankings_counts_raw.each do |id, count|
      rankings_counts[id] = count
    end
    rankings_counts
  end

  def self.write_to_db(related_games)
    Rails.logger.info "writing simular games to database"
    version = SimularGame.get_next_version
    related_games.each do |game_id, simularities|
      simularities.each do |simular_game_id, score|
        sg = SimularGame.new
        sg.game_id = game_id
        sg.simular_game_id = simular_game_id
        sg.version = version
        sg.score = score
        sg.algorithm = ALGORITHM_ID
        sg.save!
      end
    end
  end
end