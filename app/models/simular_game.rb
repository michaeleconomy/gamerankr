#note abotu version numbers - two algorithms cannot share a version number!
class SimularGame < ApplicationRecord
  belongs_to :game
  belongs_to :simular_game, :foreign_key => "simular_game_id", :class_name => "Game"

  def self.get_for_game(game)
    game.simular_games.where(version: current_version).order("score desc")
  end

  def self.generate
    SimularGames::UsersAlsoRatedHighly.generate
  end

  def self.current_version
    maximum(:version)
  end

  def self.get_next_version
    (current_version || 0) + 1
  end
end
