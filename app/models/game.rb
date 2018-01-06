class Game < ActiveRecord::Base
  has_many :publisher_games, :dependent => :destroy
  has_many :publishers, :through => :publisher_games

  has_many :developer_games, :dependent => :destroy
  has_many :developers, :through => :developer_games

  has_many :designer_games, :dependent => :destroy
  has_many :designers, :through => :designer_games
  
  has_many :ports, :dependent => :destroy
  has_many :platforms, :through => :ports
  
  has_many :rankings
  
  has_many :game_genres, :dependent => :destroy
  has_many :genres, :through => :game_genres
  
  has_many :game_series, :dependent => :destroy
  has_many :series, :through => :game_series
  
  validates_length_of :title, :in => 1..255
  
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
    genre = Genre.find_or_initialize_by(:name => genre_name)
    game_genres.create(:genre => genre, :game => self)
    genre
  end

  def split
    ps = ports.all
    ps.shift
    ps.each do |p|
      p.split
    end
    
    self
  end
  
  def self.get_by_title(title)
    where("lower(title) = ?", title.downcase).first || new(:title => title)
  end

  # please note - returns ports (but aggregated at the game level)
  def self.popular_ports
    port_ids = popular_query.pluck("min(port_id)")
    Port.where(id: port_ids)
  end

  def self.popular
    where(id: popular_query.pluck("game_id"))
  end

  private

  def self.popular_query
    Ranking.where("created_at > ?", 3.months.ago).
      group(:game_id).
      order("count(1) desc").
      limit(36)
  end
end
