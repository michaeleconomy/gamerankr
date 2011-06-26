class Genre < ActiveRecord::Base
  has_many :game_genres, :dependent => :destroy
  has_many :games, :through => :game_genres
  
  validates_length_of :name, :in => 3..100
  validates_uniqueness_of :name
  
  def to_display_name
    name
  end
  
  def to_param
    "#{id}-#{name.gsub(/[^\w]/, '-')}"
  end
end
