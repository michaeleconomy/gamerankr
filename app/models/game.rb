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

  has_many :game_franchises, dependent: :destroy
  has_many :franchises, through: :game_franchises
  
  has_many :game_series, dependent: :destroy
  has_many :series, through: :game_series

  has_many :simular_games, dependent: :destroy
  has_many :simular_games_reverse,
    class_name: "SimularGame",
    foreign_key: "simular_game_id",
    dependent: :destroy

  has_many :recommendations, dependent: :destroy

  belongs_to :best_port,
     class_name: "Port",
    foreign_key: "best_port_id"

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

  def sum_rankings
    rankings.where("ranking is not null").sum(:ranking) || 0
  end

  def count_ranked
    rankings.where("ranking is not null").count || 0
  end

  def alternate_names_list
    alternate_names.split(";").map(&:strip)
  end
  
  def add_genre(genre_name)
    if genre_name.blank?
      return nil
    end
    
    if genre = genres.detect{|g| g.name.casecmp(genre_name) == 0}
      return genre
    end
    genre = Genre.get(genre_name)
    if !genre
      return nil
    end
    if id
      if !game_genres.create(genre: genre)
        logger.error "couldn't save game_genre: #{id} #{genre.id}"
        return nil
      end
    end
    genre
  end

  def set_genres(new_genres)
    remaining = Array.new(genres)
    for new_genre in new_genres
      added = add_genre new_genre
      remaining.delete added
    end

    for old_genre in remaining
      game_genres.where(genre_id: old_genre.id).destroy_all
    end
    true
  end


  def set_alternate_names(names)
    self.alternate_names = names.map{|n| n.strip.gsub(";", ",")}.join(";")
  end


  def set_franchises(new_franchises)
    remaining = Array.new(franchises)
    for new_franchise_name in new_franchises
      franchise = Franchise.get new_franchise_name
      if !franchise
        next
      end
      if franchises.include?(franchise)
        remaining.delete franchise
        next
      end
      if !game_franchises.create franchise: franchise
        logger.error "couldn't save game_franchise: #{id} #{franchise.id}"
      end
    end

    for old_franchise in remaining
      game_franchises.where(franchise_id: old_franchise.id).destroy_all
    end
    true
  end

  def set_series(new_serieses)
    remaining = Array.new(series)
    for new_series_name in new_serieses
      the_series = Series.get new_series_name
      if !the_series
        next
      end
      if series.include?(the_series)
        remaining.delete the_series
        next
      end
      if !game_series.create series: the_series
        logger.error "Couldn't save game_series: #{id}, #{the_series.id}"
      end
    end

    for old_series in remaining
      game_series.where(series_id: old_series.id).destroy_all
    end
    true
  end
  
  def add_publisher(publisher_name)
    if publisher_name.blank?
      return nil
    end
    
    if publisher = publishers.detect{|g| g.name.casecmp(publisher_name) == 0}
      return publisher
    end
    publisher = Publisher.get(publisher_name)
    if !publisher
      return nil
    end
    publisher_games.create(publisher: publisher)
    publisher
  end

  def set_developers(new_developers)
    remaining = Array.new(developers)
    for new_developer in new_developers
      added = add_developer new_developer
      remaining.delete added
    end

    for old_developer in remaining
      developer_games.where(developer_id: old_developer.id).destroy_all
    end
    true
  end

  def set_publishers(new_publishers)
    remaining = Array.new(publishers)
    for new_publisher in new_publishers
      added = add_publisher new_publisher
      remaining.delete added
    end

    for old_publisher in remaining
      publisher_games.where(publisher_id: old_publisher.id).destroy_all
    end
    true
  end
  
  def add_developer(developer_name)
    if developer_name.blank?
      return nil
    end
    
    if developer = developers.detect{|g| g.name.casecmp(developer_name) == 0}
      return developer
    end
    developer = Developer.get(developer_name)
    if !developer
      return nil
    end
    developer_games.create(developer: developer)
    developer
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
      where("initially_released_at <= ?", Date.today)
  end

  def self.unreleased
    where("initially_released_at is not null").
      where("initially_released_at > ?", Date.today)
  end

  def self.default_preload
    preload(:genres, best_port: [:additional_data, :game], ports: :platform)
  end

  def self.search(query)
    where("unaccent(lower(title)) like unaccent(lower(?)) OR " +
      "unaccent(lower(alternate_names)) like unaccent(lower(?))",
      "%#{query}%",
      "%#{query}%")
  end

  private

  def self.popular_query
    Ranking.where("created_at > ?", 3.months.ago).
      group(:game_id).
      order(Arel.sql("count(1) desc, max(created_at) desc")).
      limit(36)
  end
end
