class PublisherGame < ActiveRecord::Base
  belongs_to :game
  belongs_to :publisher
  
  validates_uniqueness_of :game_id, scope: :publisher_id
end
