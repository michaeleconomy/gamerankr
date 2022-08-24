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
    find_or_create_by!(name: franchise_name)
  end
end
