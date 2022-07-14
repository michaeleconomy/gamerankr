class RankingShelf < ActiveRecord::Base
  belongs_to :shelf, counter_cache: true
  belongs_to :ranking

  
  validates_uniqueness_of :ranking_id, :scope => :shelf_id, :on => :create,
    :message => "That game is already on this shelf"
  validates_presence_of :shelf
  validates_presence_of :ranking, :if => lambda {|rs| rs.ranking_id?}
  attr_readonly :ranking_id
  
  validate :user_ids_match

  after_commit :update_ranking_updated_at, on: [:create, :update]
  
  def user_ids_match
    if ranking && shelf && ranking.user_id != shelf.user_id
      errors.add(:ranking, 'owner mismatch!')
    end
  end

  def update_ranking_updated_at
    if ranking && ranking.updated_at < 12.hours.ago
      ranking.updated_at = Time.now
      ranking.save!
    end
  end

end
