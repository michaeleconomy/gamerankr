class SimularGame < ApplicationRecord
  belongs_to :game
  belongs_to :simular_game, :foreign_key => "simular_game_id", :class_name => "Game"

  def self.get_for_game(game)
    game.simular_games.where(version: current_version(SimularGames::UsersAlsoRatedHighly::ALGORITHM_ID)).order("score desc")
  end

  def self.generate
    SimularGames::UsersAlsoRatedHighly.generate
  end

  def self.current_version(algorithm_id)
    where(algorithm: algorithm_id).maximum(:version)
  end

  def self.get_next_version(algorithm_id)
    (current_version(algorithm_id) || 0) + 1
  end

  def self.delete_old_versions(algorithm_id)
    where(algorithm: algorithm_id).where("version < ?", current_version(algorithm_id)).delete_all
  end
end
