class Publisher < ActiveRecord::Base
  has_many :publisher_games
  has_many :games, through: :publisher_games
  
  validates_length_of :name, minimum: 1
  validates_uniqueness_of :name
  
  def to_display_name
    name
  end
  
  def to_param
    "#{id}-#{name.gsub(/[^\w]/, '-')}"
  end

  def self.get(name)
    publisher = find_or_create_by(name: name)
    if !publisher.id
      logger.error "publisher could not be created: #{name}"
      return nil
    end
    publisher
  end
end
