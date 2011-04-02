class Game < ActiveRecord::Base
  has_many :publisher_games
  has_many :publishers, :through => :publisher_games

  has_many :developer_games
  has_many :developers, :through => :developer_games

  has_many :designer_games, :dependent => :destroy
  has_many :designers, :through => :designer_games
  
  has_many :ports, :dependent => :destroy
  has_many :platforms, :through => :ports
  
  has_many :rankings, :dependent => :destroy
  
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
    rankings.where("ranking is not null").average(:ranking)
  end
end
