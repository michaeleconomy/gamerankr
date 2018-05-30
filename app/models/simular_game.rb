class SimularGame < ApplicationRecord

  def self.generate
    version = get_next_version
    Rails.logger.info("grabbing raw rankings from db")
    rankings = Ranking.pluck(:user_id, :game_id, :ranking)
    simularity_counts = get_simularity_counts(rankings)

    related_games = limit_to_best(simularity_counts)
    related_games.each do |game_id, simularities|
      puts "#{game_id} - #{simularities.collect(&:first).join(" ")}"
    end
    nil
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
          simularity_counts[game_id][game_id2] += 1
        end
      end
    end

    simularity_counts
  end

  def self.limit_to_best(simularity_counts)
    simularity_counts.collect do |game_id, simularities|
      simluarities_limited =
        simularities.to_a.shuffle.sort_by{|id, score| -score}.first(10)
      [game_id, simluarities_limited]
    end
  end


  def self.get_next_version
    (minimum(:version) || 0) + 1
  end
end
