class Series < ActiveRecord::Base
  has_many :game_series
  has_many :games, through: :game_series
  
  validates_length_of :name, in: 2..128
  
  def to_display_name
    name
  end
  
  def to_param
    "#{id}-#{name.gsub(/[^\w]/, '-')}"
  end

  def self.get(series_name)
    return nil if series_name.length > 128

    series = find_or_create_by(name: series_name)
    if !series.id
      logger.error "series could not be created: #{series_name}"
      return nil
    end
    series
  end
end
