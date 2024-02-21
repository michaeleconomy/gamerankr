class SessionsController < ApplicationController
  def create
    flash[:notice] = "Welcome back, #{current_user.real_name}."

    redirect_to "/"
  end

  def mobile_login
    user = nil
    if params[:email] && params[:password]
      user = User.where("lower(email) = lower(?)", params[:email]).first
      if !user
        render json: "Invalid Email", status: 404
        return
      end
      if !user.authenticate params[:password]
        render json: "Invalid Password", status: 400
        return
      end
      if !user.verified?
        if !params[:no_verify_email]
          AuthMailer.verify(user).deliver_later
          session[:last_verification_email_at] = Time.now
          session[:unverified_email] = params[:email]
        end
        render json: {unverified: "yes"}, status: 200
        return
      end
    else
      render json: "Invalid Request", status: 400
      return
    end

    ios_authorization = user.ios_authorization
    if !ios_authorization
      ios_authorization = user.create_ios_authorization!(
        provider: 'gamerankr-ios',
        uid: user.id,
        token: rand(2**512).to_s(36))
    end

    response = {token: ios_authorization.token, current_user_id: user.id.to_s}
    
    if @new_user
      response[:new_user] = true
    end

    render json: response
  end

end
