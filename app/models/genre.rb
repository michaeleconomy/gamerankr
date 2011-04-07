class Genre < ActiveRecord::Base
  has_many :game_genres, :dependent => :destroy
  has_many :games, :through => :game_genres
  
  validates_length_of :name, :in => 3..100
  
  def to_display_name
    name
  end
end
