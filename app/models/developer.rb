class Developer < ActiveRecord::Base
  has_many :developer_games
  has_many :games, :through => :developer_games
  has_many :ports, :through => :developer_games
  
  validates_length_of :name, :minimum => 1
  
  def to_display_name
    name
  end
end
