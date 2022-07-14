class Designer < ActiveRecord::Base
  has_many :designer_games, dependent: :destroy
  has_many :games, through: :designer_games
  
  validates_length_of :name, minimum: 1
  validates_uniqueness_of :name
  
  
  def to_param
    "#{id}-#{name.gsub(/[^\w]/, '-')}"
  end
end
