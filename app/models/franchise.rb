class Franchise < ApplicationRecord
  has_many :game_franchises, dependent: :destroy
  has_many :games, through: :game_franchises

  def to_display_name
    name
  end
  
  def to_param
    "#{id}-#{name.gsub(/[^\w]/, '-')}"
  end

  def self.get(franchise_name)
    franchise = find_or_create_by(name: franchise_name)
    if !franchise.id
      logger.error "franchise could not be created: #{franchise_name}"
      return nil
    end
    franchise
  end
end
