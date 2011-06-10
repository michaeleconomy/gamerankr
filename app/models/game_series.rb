class GameSeries < ActiveRecord::Base
  belongs_to :game
  belongs_to :series
  
  validates_presence_of :game, :series
  
  accepts_nested_attributes_for :series
  
  acts_as_list :scope => :series
  
  
  def series_name?
    !series_name.blank?
  end
  
  def series_name
    series && series.name
  end
  
  def series_name=(q)
    self.series = Series.find_or_initialize_by_name(q)
  end
end
