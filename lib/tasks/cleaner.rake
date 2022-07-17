namespace :clean do
  desc "remove unranked games"
  task unranked_games: [:environment] do
    total = Game.count
    unranked = Game.where("rankings_count <= 0").count
    ranked = Ranking.count("distinct(game_id)")

    if total != ranked + unranked
      puts "The counts appear to be off, not deleting"
    else
      Game.where("rankings_count <= 0").destroy_all
    end
  end
end