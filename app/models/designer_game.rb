class DesignerGame < ActiveRecord::Base
  belongs_to :game
  belongs_to :designer
  
  validates_uniqueness_of :game_id, :scope => :designer_id
end
