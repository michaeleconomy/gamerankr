class PublisherGame < ActiveRecord::Base
  belongs_to :game
  belongs_to :port
  belongs_to :publisher
  
  def before_validation
    self.game_id ||= port.game_id if port_id_changed? && port
    
    true
  end
end
