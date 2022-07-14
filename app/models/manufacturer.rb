class Manufacturer < ActiveRecord::Base
  has_many :platforms, dependent: :nullify
  
  validates_length_of :name, in: 1..128
  validates_uniqueness_of :name
  
  def to_display_name
    name
  end
  
  def to_param
    "#{id}-#{name.gsub(/[^\w]/, '-')}"
  end
end
