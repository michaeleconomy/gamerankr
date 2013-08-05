class ProfileQuestionsController < ApplicationController
  before_filter :require_admin
  before_filter :load_profile_question, :only => [:update, :destroy]
  
  def index
    @profile_questions =
      ProfileQuestion.order('shown desc').paginate :page => params[:page]
  end
  
  def update
    if @profile_question.update_attributes(profile_questions_params)
      render :text => "updated"
      return
    end
    render :text => @profile_question.errors.full_messages.to_sentence,
      :status => 400
  end
  
  def destroy
    @profile_question.destroy
    render :text => "deleted"
  end
  
  
  private
  
  def profile_questions_params
    params.require(:profile_questions).permit(:question, :answer)
  end
end
