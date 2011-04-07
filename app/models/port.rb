class Port < ActiveRecord::Base
  belongs_to :game
  belongs_to :platform
  
  has_many :rankings, :dependent => :destroy
  has_many :publishers, :through => :publisher_games
  has_many :publisher_games, :dependent => :destroy
  
  has_many :developers, :through => :developer_games
  has_many :developer_games, :dependent => :destroy
  
  validates_length_of :title, :minimum => 1
  after_save :set_game_release_at
  after_destroy :delete_empty_game
  
  def set_game_release_at
    if game_id_changed? && released_at
      if !game.initially_released_at || game.initially_released_at > released_at
        game.update_attributes(
          :initially_released_at => released_at,
          :initially_released_at_accuracy =>  released_at_accuracy)
      end
    end
    
    true
  end
  
  def resized_amazon_image_url(size)
    return unless amazon_image_url
    amazon_image_url.sub(".jpg", "._#{size}_.jpg").sub(".gif", "._#{size}_.gif")
  end
  
  def to_display_name
    title
  end
  
  def amazon_affiliate_url
    amazon_url + "&tag=gamerankr-20"
  end
    
  
  def self.with_image
    where("amazon_image_url is not null")
  end
  
  # def self.merge(ports)
  #   ports = ports.compact
  #   return if ports.size <= 1
  #   
  #   
  #   
  # end
  
  private
  
  def delete_empty_game
    if game && game.ports.count == 0
      game.destroy
    end
    
    true
  end
end
