class Series < ActiveRecord::Base
  has_many :game_series
  has_many :games, through: :game_series
  
  validates_length_of :name, in: 2..128
  
  def to_display_name
    name
  end
  
  def to_param
    "#{id}-#{name.gsub(/[^\w]/, '-')}"
  end
end
