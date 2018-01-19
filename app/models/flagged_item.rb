class FlaggedItem
  TYPES = {
    "Ranking" => Ranking,
    "Game" => Game,
    "Comment" => Comment
  }

  def self.get_type(string)
    TYPES[string]
  end
end