class Game < ActiveRecord::Base
  # include Elasticsearch::Model
  # include Elasticsearch::Model::Callbacks
  # index_name "#{Rails.env}-#{table_name}"
  # def as_indexed_json(options = nil)
  #   self.as_json( only: [ :title, :initially_released_at, :rankings_count], methods: [:platform_names])
  # end

  has_many :publisher_games, dependent: :destroy
  has_many :publishers, through: :publisher_games

  has_many :developer_games, dependent: :destroy
  has_many :developers, through: :developer_games

  has_many :designer_games, dependent: :destroy
  has_many :designers, through: :designer_games
  
  has_many :ports, dependent: :destroy
  has_many :platforms, through: :ports
  
  has_many :rankings
  
  has_many :game_genres, dependent: :destroy
  has_many :genres, through: :game_genres
  
  has_many :game_series, dependent: :destroy
  has_many :series, through: :game_series

  has_many :simular_games, dependent: :destroy
  has_many :simular_games_reverse,
    class_name: "SimularGame",
    foreign_key: "simular_game_id",
    dependent: :destroy

  has_many :recommendations, dependent: :destroy

  belongs_to :best_port,
    :class_name => "Port",
    :foreign_key => "best_port_id"

  validates_length_of :title, in: 1..255
  
  def to_param
    "#{id}-#{title.gsub(/[^\w]/, '-')}"
  end
  
  def to_display_name
    title
  end
  
  def port
    Rails.logger.warn "game.port is depricated, use best_port instead.  Called from: #{caller[0]}"
    ports.first
  end

  def platform_names
    platforms.collect(&:name)
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
    genre = Genre.find_or_initialize_by(name: genre_name)
    game_genres.create(genre: genre, game: self)
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

  def set_best_port
    best_port = ports.sort_by{|p| -p.rankings_count}.first
    update best_port_id: best_port && best_port.id
  end
  
  def self.get_by_title(title)
    where(Arel.sql("lower(title) = ?"), title.downcase).first || new(title: title)
  end

  # please note - returns ports (but aggregated at the game level)
  def self.popular_ports
    port_ids = popular_query.pluck(Arel.sql("min(port_id)"))
    ports = Port.where(id: port_ids).default_preload
    port_ids.map{|id| ports.find{|port| port.id == id}}
  end

  def self.popular
    where(id: popular_query.pluck(:game_id))
  end

  def self.released
    where("initially_released_at is not null").
      where("initially_released_at <= ?", Time.now)
  end

  def self.unreleased
    where("initially_released_at is not null").
      where("initially_released_at > ?", Time.now)
  end

  def self.default_preload
    preload(best_port: [:additional_data, :game], ports: :platform)
  end

  private

  def self.popular_query
    Ranking.where("created_at > ?", 3.months.ago).
      group(:game_id).
      order(Arel.sql("count(1) desc, max(created_at) desc")).
      limit(36)
  end
end
