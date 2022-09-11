class ContactController < ApplicationController

  before_action :require_sign_in, :except => [:index, :submit]
  

  @@captchas = {
    "What color clothing does Mario wear?": ["red"],
    "What is Mario's profession?": ["plumber"],
    "Sonic is what kind of animal?": ["hedgehog", "hedge hog"],
    "What color is Sonic?": ["blue"],
    "What is Sonic's partner's name?": ["tails"],
    "Name an extremely popular electric rat pokemon": ["pikachu"],
    "This popular nintendo franchise is a portmanteau of the words 'pocket monsters'": ["pokemon", "pokémon"],
    "This plumber is possibly nintendo's most popular character": ["mario"],
    "The name of the protagonist of the Zelda games": ["link"],
    "What piece of jewelry is a heirloom belonging to Nathan Drake?": ["ring"],
    "What is Nathan Drake's older partner's name?": ["scully", "sculy", "victor", "victor sullivan", "sully"],
    "Who is the protagonist of the Uncharted Series": ["nate", "nathan", "nathan drake", "drake"],
    "Rainbow road is a race track in this popular nintendo title.": ["mariokart", "mario kart"],
    "Solid snake is the protagonist of this video game series": ["metal gear solid", "metal gear"],
    "What game by id Software has players going to mars for fight demons?": ["doom"],
    "What does the A in Rockstar Games' popular GTA series stand for?": ["auto"],
    "What is the name of Epic game's popular multiplayer online battle arena game?": ["fortnite"],
    "In this popular title you use remote control cars to play soccer": ["rocket league"],
    "Which nintendo console featured the first analog stick?": ["nintendo 64", "n64"],
    "What popular device was Sony's first video game console?": ["playstation"],
    "Who is the most common antagonist of the Mario Brothers?": ["bowser", "king koopa"],
    "Bowser (the large spiney dinosaur from many mario games) is also known as king ____?": ["koopa"],
    "Which princess is mario in love with?": ["peach"],
    "Princess Peach generally lives in, and rules over which kingdom?": ["mushroom"],

  }

  def index
    if signed_out?
      @captcha = session[:captcha] = @@captchas.keys.sample
    end
  end

  def submit
    if signed_out?
      if !session[:captcha]
        flash[:error] = "Captcha question is required"
        redirect_to contact_path
        return
      end
      answers = @@captchas[session[:captcha]]
      
      if !answers
        flash[:error] = "Captcha question is required"
        redirect_to contact_path
        return
      end
      cleaned_answer = (params[:answer] || "").strip.downcase
      if !answers.include?(cleaned_answer)
        flash[:error] = "incorrect answer to the captcha question"
        redirect_to contact_path
        return
      end
      if !verify_captacha
        flash[:error] = "There was a problem submitting your request, please try again"
        redirect_to contact_path
        return
      end
    end
    email = params[:email]
    if !User.email_regex.match?(email)
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

    if SpamFilter.filter(params[:email] + params[:subject] + params[:body])
      logger.info "spam filtered"
    else
      ContactMailer.contact(user_id, data).deliver_later
    end

    flash[:notice] = "Thanks for contacting GameRankr!"
    redirect_to "/"
  end

  private

  def verify_captacha
    uri = URI::HTTPS.build(
      host: "www.google.com", 
      path: "/recaptcha/api/siteverify",
      query: {
        secret: "6LeH99EhAAAAAEGp23voSu4mscnAUTNRHNHet5DJ",
        response: params["g-recaptcha-response"],
        remoteip: request.ip
      }.to_query)

    response = Net::HTTP.get_response(uri)
    if !response.is_a?(Net::HTTPSuccess)
      Rails.logger.info "recaptcha response #{response.code} - #{response.body}"
      return false
    end
    Rails.logger.info "recaptcha response success #{response.body}"
    json = JSON.parse(response.body)
    json["success"]
  end
end