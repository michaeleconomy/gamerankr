class PublisherGame < ActiveRecord::Base
  belongs_to :game
  belongs_to :port
  belongs_to :publisher
  
  validates_uniqueness_of :port_id, :scope => :publisher
  
  before_validation :set_game_id
  
  
  def set_game_id
    self.game_id ||= port.game_id if port_id_changed? && port
    
    true
  end
end
