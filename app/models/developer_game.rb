class DeveloperGame < ActiveRecord::Base
  belongs_to :developer
  belongs_to :game
  validates_uniqueness_of :game_id, scope: :developer_id
end
