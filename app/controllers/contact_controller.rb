class ContactController < ApplicationController

  before_action :require_sign_in, :except => [:index, :submit]
  
  def index

  end

  def submit
    data = {
      email: params[:email],
      subject: params[:subject],
      body: params[:body],
      user_agent: request.user_agent,
      ip: request.remote_ip
    }

    user_id = current_user && current_user.id

    ContactJob.perform_async(user_id, data)
    flash[:notice] = "Thanks for contacting GameRankr!"
    redirect_to "/"
  end
end