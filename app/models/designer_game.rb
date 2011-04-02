class DesignerGame < ActiveRecord::Base
  belongs_to :game
  belongs_to :designer
  
end
