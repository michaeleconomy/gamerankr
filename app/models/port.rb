class Port < ActiveRecord::Base
  belongs_to :game
  belongs_to :platform
  belongs_to :additional_data, polymorphic: true
  
  has_many :rankings
  
  RELEASED_AT_ACCURACIES = [nil, "day", "month", "year"]
  
  validates_length_of :title, in: 1..255
  validates_presence_of :game, :platform
  validates_inclusion_of :released_at_accuracy, in: RELEASED_AT_ACCURACIES
  
  before_validation :fix_released_at_accuracy
  before_validation :set_game_title, on: :create
  after_save :set_game_release_at
  after_destroy :delete_empty_game
  
  
  
  #additional_data_passthroughs
  def large_image_url
    additional_data && additional_data.large_image_url
  end

  def small_image_url
    additional_data && additional_data.small_image_url
  end

  def small_image_url
    additional_data && additional_data.medium_image_url
  end
  
  def price?
    !price.nil?
  end
  
  def price
    additional_data && additional_data.price
  end
  
  def affiliate_url
    additional_data && additional_data.affiliate_url
  end
  
  def has_image?
    additional_data && !additional_data.resized_image_url("SX25").nil?
  end
  
  def resized_image_url(size)
    additional_data && additional_data.resized_image_url(size)
  end
  
  def additional_description
    additional_data && additional_data.description
  end
  # end of additional data_passthroughs
  
  def best_description
    if description?
      description
    else
      additional_description
    end
  end
  
  def best_description?
    !best_description.blank?
  end
  
  def to_display_name
    title
  end
  
  def set_game
    self.game ||= Game.get_by_title(title)
  end
  
  def add_developer(developer_name)
    if developer_name.blank?
      return
    end
    developer = Developer.find_or_initialize_by(name: developer_name)

    if developers.include?(developer)
      return developer
    end
    developer_games.build(developer: developer, port: self)
    developer
  end
  
  def to_param
    "#{id}-#{title.gsub(/[^\w]/, '-')}"
  end
  
  def split
    self.game = Game.new title: title
    self.game.save!
    save!
    developer_games.update_all(["game_id = ?", game_id])
    publisher_games.update_all(["game_id = ?", game_id])
    rankings.update_all(["game_id = ?", game_id])
  end
  
  def average_ranking
    rankings.where("ranking is not null").average(:ranking) || 0
  end

  def self.default_preload
    preload(:additional_data, :platform, game: [:genres, {ports: :platform}])
  end


  def self.search(query)
    where("unaccent(lower(title)) like unaccent(lower(?))", "%#{query}%")
  end
  
  private
  
  def set_game_title
    if game
      game.title ||= title
    end
    
    true
  end
  
  def set_game_release_at
    if saved_change_to_game_id? && released_at
      if !game.initially_released_at || game.initially_released_at > released_at
        game.update(
          initially_released_at: released_at,
          initially_released_at_accuracy: released_at_accuracy)
      end
    end
    
    true
  end
  
  def delete_empty_game
    if game && game.ports.count == 0
      game.destroy
    end
    
    true
  end
  
  
  def fix_released_at_accuracy
    if !released_at || !released_at_accuracy?
      self.released_at_accuracy = nil
    end
      
    true
  end
end
