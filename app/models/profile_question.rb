class ProfileQuestion < ActiveRecord::Base
  belongs_to :created_by_user
  has_many :user_profile_questions, :dependent => :destroy
  
  validates_length_of :question, :in => 2..4000
  validate :validate_question_is_unique
  validates_presence_of :created_by_user
  before_validation :set_hashed_question
  
  def self.shown
    where(:shown => true)
  end
  
  def self.get_question(question)
    find_or_initialize_by_hashed_question_and_question(question.hash, question)
  end
  
  private
  
  def validate_question_is_unique
    if question?
      possible_dup = self.class.find_by_hashed_question(hashed_question)
      if possible_dup && possible_dup.question == question
        errors.add :question, "duplicate!"
      end
    end
  end
  
  def set_hashed_question
    self.hashed_question = question.hash
  end
  
end
