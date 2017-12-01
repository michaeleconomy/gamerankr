class Platform < ActiveRecord::Base
  has_one :giant_bomb_platform, :dependent => :destroy

  has_many :ports, :dependent => :nullify
  has_many :platform_aliases, :dependent => :destroy
  has_many :games, :through => :ports
  belongs_to :manufacturer, :counter_cache => true
  
  validates_length_of :name, :minimum => 1
  validates_uniqueness_of :name
  validate :name_not_in_aliases
  
  def manufacturer_name
    manufacturer && manufacturer.name
  end
  
  def manufacturer_name=(new_name)
    if manufacturer_name == new_name
      return new_name
    end
    self.manufacturer = Manufacturer.find_or_initialize_by_name(new_name)
    new_name
  end
  
  def to_display_name
    name
  end
  
  def to_param
    "#{id}-#{name.gsub(/[^\w]/, '-')}"
  end
  
  def merge(platform)
    platform_aliases.create(:name => platform.name)
    platform.ports.update_all(["platform_id = ?", id])
    platform.platform_aliases.update_all(["platform_id = ?", id])
    platform.destroy
    
    true
  end
  
  def self.get_by_name(name)
    if platform = find_by_name(name)
      return platform
    end
      
    if plaform_alias = PlatformAlias.find_by_name(name)
      return plaform_alias.platform
    end
    
    nil
  end
  
  private
  
  def name_not_in_aliases
    if name && PlatformAlias.find_by_name(name)
      errors.add(:name, "is already taken")
    end
  end
end
