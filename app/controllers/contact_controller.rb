class ContactController < ApplicationController

  before_action :require_sign_in, :except => [:index]
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

    ContactJob.perform_async(current_user.id, data)
    flash[:notice] = "Thanks for contacting GameRankr!"
    redirect_to "/"
  end
end