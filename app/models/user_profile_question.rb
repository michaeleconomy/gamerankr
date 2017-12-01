class UserProfileQuestion < ActiveRecord::Base
  belongs_to :user
  belongs_to :profile_question
  
  
  validates_length_of :answer, :in => 2..4000
  validates_presence_of :profile_question, :user
  
  before_validation :set_profile_question_user_id
  
  def question?
    !question.blank?
  end
  
  def question
    profile_question && profile_question.question
  end
  
  def question=(q)
    self.profile_question = ProfileQuestion.find_or_initialize_by(question: q)
  end
  
  private
  
  def set_profile_question_user_id
    if profile_question
      profile_question.created_by_user_id ||= user_id
    end
  end
end
