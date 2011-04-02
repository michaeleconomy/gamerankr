class DeveloperGame < ActiveRecord::Base
  belongs_to :developer
  
  include GameIdSetter
end
