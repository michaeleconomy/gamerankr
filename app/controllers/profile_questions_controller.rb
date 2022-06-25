class ProfileQuestionsController < ApplicationController
  before_action :require_admin
  before_action :load_profile_question, :only => [:update, :destroy]
  
  def index
    @profile_questions =
      ProfileQuestion.order('shown desc').paginate :page => params[:page]
  end
  
  def update
    if @profile_question.update(profile_questions_params)
      render :plain => "updated"
      return
    end
    render :plain => @profile_question.errors.full_messages.to_sentence,
      :status => 400
  end
  
  def destroy
    @profile_question.destroy
    render :plain => "deleted"
  end
  
  
  private
  
  def profile_questions_params
    params.require(:profile_questions).permit(:question, :answer)
  end
end
