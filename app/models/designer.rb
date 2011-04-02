class Designer < ActiveRecord::Base
  validates_length_of :name, :minimum => 1
end
