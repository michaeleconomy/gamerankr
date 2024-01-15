class UsersController < ApplicationController
  before_action :load_user,
    only: [:show, :edit, :edit_email_preference, :update, :destroy]
  before_action :require_sign_in,
    except: [:show, :index, :all]
  before_action :require_admin_unless_current_user,
    only: [:edit, :edit_email_preference, :update, :destroy]
  
  def index
    @popular = User.follow_order.limit(20).to_a
    recent_user_ids = Ranking.order("max(id) desc").
      group("user_id").
      limit(20).
      pluck("user_id, max(id)").
      map{|a| a[0]}
    @recent = User.find(recent_user_ids)
    get_followings @popular + @recent
  end

  def all
    @users = User.order("id").
      where("rankings_count > 0").
      paginate page: params[:page]
    get_followings
  end

  def search
    if !params[:query]
      return
    end

    if User.email_regex.match?(params[:query])
      @users = [User.where("lower(email) = lower(?)", params[:query]).first].compact
    else
      @users = User.where("unaccent(lower(real_name)) like unaccent(lower(?))", "%#{params[:query]}%").
        paginate(page: params[:page])
    end

    get_followings
  end
  
  def show
    @self = @user == current_user
    if !@self && signed_in?
      @following = @user.followers.where(follower_id: current_user.id).exists?
      @follower = @user.followings.where(following_id: current_user.id).exists?
    end
    @followings = @user.following_users.
      follow_order.
      limit(5)
    @followers = @user.follower_users.
      follow_order.
      limit(5)

    @rankings = @user.rankings.
      includes(:game, :shelves, port: :additional_data).
      limit(20).
      order("updated_at desc")
    get_rankings
    @user_profile_questions =
      @user.user_profile_questions.includes(:profile_question)
    get_followings [@user]
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
    end
    render :action => 'edit'
  end
  
  def update
    @user.attributes = 
      params.require(:user).
      permit(:real_name, :handle, :about, :location,
        :comment_notification_email, :friend_update_email, :new_follower_email,
        user_profile_questions_attributes: [:id, :question, :answer, :_destroy])
    
    if !@user.save
      render action: 'edit'
      return
    end
    flash[:notice] = "Profile has been updated!"
    redirect_to @user
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
