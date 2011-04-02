class RankingShelf < ActiveRecord::Base
  belongs_to :shelf, :counter_cache => true
  belongs_to :ranking

  
  validates_uniqueness_of :ranking_id, :scope => :shelf_id, :on => :create
  validates_presence_of :shelf
  validates_presence_of :ranking, :if => lambda {|rs| rs.ranking_id?}
  attr_readonly :ranking_id
  
  validate :user_ids_match
  
  def user_ids_match
    if ranking && shelf && ranking.user_id != shelf.user_id
      errors.add(:ranking, 'owner mismatch!')
    end
  end
end
