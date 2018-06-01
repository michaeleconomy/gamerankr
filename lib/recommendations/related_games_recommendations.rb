class Recommendations::RelatedGamesRecommendations
  include SimularGames::SimularityHelpers

  ALGORITHM_ID = 1

  def self.generate_all
    new.go
  end


  def go
    fetch_rankings
    compute_simularity_matrix
    normalize_simularity_matrix
    generate_recommendations
    sort_and_prune_recommendations
    write_recommendations
  end

  def fetch_rankings
    Rails.logger.info "fetching all rankings from db"
    rankings = Ranking.pluck(:user_id, :game_id, :ranking)
    Rails.logger.info "hashing rankings by user"
    @rankings_by_user = Hash.new{|hash, key| hash[key] = []}
    rankings.each do |user, game, rating|
      @rankings_by_user[user] << [game, rating || 4] #treat nil as 4
    end
  end

  def compute_simularity_matrix
    Rails.logger.info "computing simularity matrix"
    @simularity_matrix = Hash.new{|hash, key| hash[key] = Hash.new(0.0)}
    @rankings_by_user.each do |user_id, rankings|
      rankings.each do |game_id1, rating1|
        game_simularities = @simularity_matrix[game_id1]
        rankings.each do |game_id2, rating2|
          next if game_id1 == game_id2
          game_simularities[game_id2] += rating_simularity(rating1, rating2)
        end
      end
    end
  end

  def rating_simularity(a, b)
    -(((a-b).abs / 2.0) - 1)
  end

  def normalize_simularity_matrix
    Rails.logger.info "normalizing simularity matrix"
    @simularity_matrix.each do |game_id1, simular_games|
      simular_games.each do |game_id2, score|
        simular_games[game_id2] = score / rankings_count(game_id2)
      end
    end
  end

  def generate_recommendations
    Rails.logger.info "generating recommendations"
    @user_recommendations = []
    @rankings_by_user.each do |user_id, rankings|
      recommendations_for_user = Hash.new(0.0)
      rankings.each do |user_game, rating|
        normalized_rating = normalize_rating(rating)
        @simularity_matrix[user_game].each do |related_game, score|
          recommendations_for_user[related_game] += score * normalized_rating
        end
      end

      #remove games a user has already added
      rankings.each do |user_game, rating1|
        recommendations_for_user.delete(user_game)
      end
      @user_recommendations << [user_id, recommendations_for_user.to_a]
    end
  end

  def sort_and_prune_recommendations
    Rails.logger.info "pruning and sorting recommendations"
    @user_recommendations.each do |user, recommendations|
      recommendations.sort_by!{|game, score| [-score, -average_rating(game)]}
      i = 0
      recommendations.reject!{ (i += 1) >= 100}
    end
  end

  def normalize_rating(r)
    (r - 3.0) / 2
  end

  def write_recommendations
    Rails.logger.info "writing recommendations to db"
    @user_recommendations.each do |user_id, recommendations|
      Recommendation.where(user_id: user_id, algorithm: ALGORITHM_ID).delete_all
      recommendations.each do |game_id, score|
        r = Recommendation.new
        r.user_id = user_id
        r.game_id = game_id
        r.score = score
        r.algorithm = ALGORITHM_ID
        r.save!
      end
    end
  end

end