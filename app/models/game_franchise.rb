class GameFranchise < ApplicationRecord
  belongs_to :game
  belongs_to :franchise
end
