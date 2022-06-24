class ContactController < ApplicationController

  before_action :require_sign_in, :except => [:index, :submit]
  

  @@captchas = {
    "What color clothing does Mario wear?": ["red"],
    "What is Mario's profession?": ["plumber"],
    "Sonic is what kind of animal?": ["hedgehog", "hedge hog"],
    "What color is Sonic?": ["blue"],
    "What is Sonic's partner's name?": ["tails"],
    "Who is Mario's brother?": ["luigi"],
    "Name an extremely popular electric rat pokemon": ["pikachu"],
    "This popular nintendo franchise is a portmanteau of the words 'pocket monsters'": ["pokemon", "pokémon"],
    "This plumber is possibly nintendo's most popular character": ["mario"],
    "The name of the protagonist of the Zelda games": ["link"],
  }
  def index
    if signed_out?
      @captcha = session[:captcha] = @@captchas.keys.sample
    end
  end

  def submit
    if signed_out?
      answers = @@captchas[session[:captcha]]
      cleaned_answer = (params[:answer] || "").strip.downcase
      if !answers.include?(cleaned_answer)
        flash[:error] = "incorrect answer to the captcha question"
        redirect_to contact_path
        return
      end
    end
    email = params[:email]
    if !Email.regex.match?(email)
      flash[:error] = "Invalid email address provided"
      redirect_to contact_path
      return
    end
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