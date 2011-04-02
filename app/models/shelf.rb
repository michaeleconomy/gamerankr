class Shelf < ActiveRecord::Base
  DEFAULT_NAMES = ["Played", "Currently Playing", "Want to Play", "Favorites", "Owned", "Beaten"]
  DEFAULTS = DEFAULT_NAMES.collect{|name| Shelf.new :name => name}
  
  belongs_to :user
  has_many :ranking_shelves, :dependent => :destroy
  has_many :rankings, :through => :ranking_shelves
  
  def to_display_name
    name
  end
end
