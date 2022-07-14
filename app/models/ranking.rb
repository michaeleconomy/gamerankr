class Ranking < ActiveRecord::Base
  
  include GameIdSetter::Callback
    
  before_validation :set_game_id
  belongs_to :game, counter_cache: true
  belongs_to :port, counter_cache: true
  
  belongs_to :user, counter_cache: true
  
  has_many :ranking_shelves, dependent: :destroy
  has_many :shelves, through: :ranking_shelves

  has_many :comments, as: :resource, dependent: :destroy
  
  validates_uniqueness_of :port_id, scope: :user_id,
    if: lambda {|r| r.port_id_changed?}
  validates_presence_of :user, :port
  
  validates_numericality_of :ranking,
    allow_nil: true,
    greater_than_or_equal_to: 1,
    less_than_or_equal_to: 5,
    only_integer: true
  
  validates_length_of :review, maximum: 10000
  validates_size_of :ranking_shelves, minimum: 1, message: "required"
  
  attr_accessor :post_to_facebook
  
  accepts_nested_attributes_for :ranking_shelves, allow_destroy: true
  
  
  before_validation :clean_review

  def self.default_preload
    preload(:game, :shelves, port: [:game, :platform, :additional_data], ranking_shelves: :shelf)
  end
  
  def clean_review
    if review?
      self.review = review.strip
      self.review = nil if review.blank?
    end
    
    true
  end
  
  def verb
    if shelves.include?("Want to Play")
      "wants to play"
    elsif review?
      "reviewed"
    elsif ranking?
      "rated"
    else
      "added"
    end
  end
  
  def self.with_review
    where("CHAR_LENGTH(review) > 0")
  end

  def self.recent_reviews
    with_review.order('rankings.id desc')
  end
end
