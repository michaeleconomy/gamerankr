class UsersController < ApplicationController
  before_filter :load_user, :only => [:show, :edit, :update, :destroy]
  before_filter :require_sign_in, :except => [:show, :index]
  before_filter :require_admin_unless_current_user, :only => [:edit, :update, :destroy]
  
  def index
    @users = User.where("rankings_count > 0").paginate :page => params[:page]
  end
  
  def show
    @rankings = @user.rankings.includes(:game, :port, :ranking_shelves => :shelf)
    @rankings = @rankings.paginate :page => params[:page]
    get_rankings
    @user_profile_questions =
      @user.user_profile_questions.includes(:profile_question)
  end
  
  def edit
    if current_user_is_user?
      new_questions = ProfileQuestion.shown
      unless @user.user_profile_questions.empty?
        pq_ids = @user.user_profile_questions.collect(&:profile_question_id)
        new_questions = new_questions.where("id not in (?)", pq_ids)
      end
      
      new_questions.each do |pq|
        @user.user_profile_questions.build(:profile_question => pq)
      end
      @user.user_profile_questions.build
    end
    render :action => 'edit'
  end
  
  def update
    @user.attributes = params[:user]
    @user.user_profile_questions.delete_if do |pq|
      pq.answer.blank? && pq.question.blank?
    end
    
    if @user.save
      redirect_to @user
      return
    end
    render :action => 'edit'
  end
  
  def destroy
    @user.destroy
    if current_user_is_user?
      session.clear
    end
    redirect_to "/"
  end
  
  private
  
  def require_admin_unless_current_user
    if current_user_is_user?
      return true
    end
    
    require_admin
  end
end
