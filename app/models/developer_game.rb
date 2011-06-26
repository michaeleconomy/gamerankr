class DeveloperGame < ActiveRecord::Base
  belongs_to :developer
  belongs_to :game
  validates_uniqueness_of :port_id, :scope => :developer_id
  
  include GameIdSetter
end
