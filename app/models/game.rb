class Game < ActiveRecord::Base
  has_many :publisher_games, :dependent => :destroy
  has_many :publishers, :through => :publisher_games

  has_many :developer_games, :dependent => :destroy
  has_many :developers, :through => :developer_games

  has_many :designer_games, :dependent => :destroy
  has_many :designers, :through => :designer_games
  
  has_many :ports, :dependent => :destroy
  has_many :platforms, :through => :ports
  
  has_many :rankings, :dependent => :destroy
  
  has_many :game_genres, :dependent => :destroy
  has_many :genres, :through => :game_genres
  
  has_many :game_series, :dependent => :destroy
  has_many :series, :through => :game_series
  
  def to_param
    "#{id}-#{title.gsub(/[^\w]/, '-')}"
  end
  
  def to_display_name
    title
  end
  
  def port
    ports.first
  end
  
  def average_ranking
    rankings.where("ranking is not null").average(:ranking) || 0
  end
  
  
  def add_genre(genre_name)
    if genre_name.blank?
      return nil
    end
    
    if genre = genres.detect{|g| g.name.casecmp(genre_name) == 0}
      return genre
    end
    genre = Genre.find_or_initialize_by_name(genre_name)
    genres << genre
    genre
  end
  
  def self.get_by_title(title)
    where("lower(title) = ?", title.downcase).first || new(:title => title)
  end
end
