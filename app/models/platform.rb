class Platform < ActiveRecord::Base
  has_many :ports, :dependent => :nullify
  has_many :games, :through => :ports
  
  
  validates_length_of :name, :minimum => 1
  
  
  def to_display_name
    name
  end
end
