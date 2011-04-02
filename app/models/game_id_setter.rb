module GameIdSetter
  
  def self.included(base)
    base.before_validation :set_game_id
    base.belongs_to :game
    base.belongs_to :port
    base.class_eval{include GameIdSetter::Callback}
  end
  
  module GameIdSetter::Callback
    def set_game_id
      self.game_id ||= port.game_id if port_id_changed? && port

      true
    end
  end
end