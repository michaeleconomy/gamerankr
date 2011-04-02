class Publisher < ActiveRecord::Base
  has_many :publisher_games
  has_many :games, :through => :publisher_games
  has_many :ports, :through => :publisher_games
  
  validates_length_of :name, :minimum => 1
  
  def to_display_name
    name
  end
end
