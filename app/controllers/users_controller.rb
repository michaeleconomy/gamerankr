class UsersController < ApplicationController
  before_action :load_user,
    :only => [:show, :edit, :edit_email_preference, :update, :destroy]
  before_action :require_sign_in, :except => [:show, :index]
  before_action :require_admin_unless_current_user,
    :only => [:edit, :edit_email_preference, :update, :destroy]
  
  def index
    @users = User.where("rankings_count > 0").paginate :page => params[:page]
  end
  
  def show
    @rankings = @user.rankings.
      includes(:game, :shelves, :port => :additional_data).
      limit(20).
      order("updated_at desc")
    get_rankings
    @user_profile_questions =
      @user.user_profile_questions.includes(:profile_question)
  end
  
  def edit
    if current_user_is_user?
      new_questions = ProfileQuestion.shown
      if !@user.user_profile_questions.empty?
        pq_ids = @user.user_profile_questions.collect(&:profile_question_id)
        new_questions = new_questions.where("id not in (?)", pq_ids)
      end
      
      new_questions.each do |pq|
        @user.user_profile_questions.build(:profile_question => pq)
      end
      @user.user_profile_questions.build
      @user.emails.build
    end
    render :action => 'edit'
  end
  
  def update
    @user.attributes = 
      params.require(:user).
      permit(:real_name, :handle, :about, :location,
        :comment_notification_email, :friend_update_email,
        :user_profile_questions_attributes => [:id, :question, :answer, :_destroy],
        :emails_attributes => [:id, :email, :primary, :_destroy])
    
    if @user.save
      flash[:notice] = "Profile has been updated!"
      redirect_to @user
      return
    end
    render :action => 'edit'
  end

  def edit_email_preference

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
