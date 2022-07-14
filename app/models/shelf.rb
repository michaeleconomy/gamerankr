class Shelf < ActiveRecord::Base
  DEFAULT_NAMES = ["Played", "Currently Playing", "Want to Play", "Favorites", "Own", "Beaten"]
  DEFAULTS = 
    begin
      DEFAULT_NAMES.collect{|name| Shelf.new name: name}
    rescue => e
      logger.error "#{e}\n#{e.backtrace}"
      []
    end
  
  belongs_to :user
  has_many :ranking_shelves, dependent: :destroy
  has_many :rankings, through: :ranking_shelves
  
  def to_display_name
    name
  end
  
  def to_param
    "#{id}-#{name.gsub(/[^\w]/, '-')}"
  end
end
