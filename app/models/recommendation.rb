class Recommendation < ActiveRecord::Base
  belongs_to :game
  belongs_to :user


  def self.generate_all
    Recommendations::RelatedGamesRecommendations.generate_all
  end
end