class BounceController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :verify_aws_authentic

  def bounce
    Rails.logger.info "handling email bounces, raw post: #{request.raw_post}"
    message = JSON.parse JSON.parse(request.raw_post)['Message']
    Rails.logger.info "handling email bounces: #{message}"


    bounce = message['bounce']

    bouncerecps = bounce['bouncedRecipients']
    bouncerecps.each do |bouncerecp|

      email = bouncerecp['emailAddress']
        
      email_model = Email.where(email: email).first
      if !email_model
        Rails.logger.warn "bounced email '#{email}'could not be found"
        next
      end
      email_model.bounce_count += 1
      email_model.last_bounce_at = Time.now
      email_model.save!
    end

    render json: {}
  end


  private

  def verify_aws_authentic
    verifier = Aws::SNS::MessageVerifier.new
    if !verifier.authentic?(request.raw_post)
      Rails.logger.info "unauthentic request discarded: #{request.raw_post}"
      render json: {}
      return false
    end

    true
  end
end

