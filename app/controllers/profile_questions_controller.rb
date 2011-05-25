class ProfileQuestionsController < ApplicationController
  before_filter :require_admin
  before_filter :load_profile_question, :only => [:update, :destroy]
  
  def index
    @profile_questions =
      ProfileQuestion.order('shown desc').paginate :page => params[:page]
  end
  
  def update
    
  end
  
  def destroy
    
  end
end
