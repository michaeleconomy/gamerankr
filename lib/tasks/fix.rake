namespace :fix do
  desc "fix rankings counter caches on games, ports"
  task ranking_counts: [:environment] do
    Tasks::CountFixer.fix_game_rankings_counts
    Tasks::CountFixer.fix_port_rankings_counts
  end

  desc "fix rankings w/o shelves"
  task shelveless: [:environment] do
    count = 0
    rs = Ranking.preload(:ranking_shelves).all
    rs.each do |r|
      if r.ranking_shelves.empty?
        shelf = r.user.shelves.find_by_name("Played")
        ranking_shelf = r.ranking_shelves.new(shelf: shelf)
        if !ranking_shelf.save
          puts "couldn't save: #{ranking_shelf.errors.inspect}"
        else
          count += 1
        end
      end
    end
    puts "fixed #{count} records"
  end
  
  desc "remove portless games"
  task portless_games: [:environment] do
    list = Game.where("id not in (select distinct(game_id) from ports)").destroy_all
    puts "deleted #{list.size} portless games"
  end
end