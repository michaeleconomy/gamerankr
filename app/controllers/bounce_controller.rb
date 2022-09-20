class BounceController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :verify_aws_authentic

  def bounce
    Rails.logger.info "handling email bounces, raw post: #{request.raw_post}"
    parsedPost = JSON.parse(request.raw_post)
    messageRaw = parsedPost['Message']
    message = JSON.parse messageRaw
    Rails.logger.info "handling email bounces: #{message}"

    bounce = message['bounce']
    if bounce
      bouncerecps = bounce['bouncedRecipients']
      if !bouncerecps
        raise "parse error"
      end

      bouncerecps.each do |bouncerecp|

        email = bouncerecp['emailAddress']
          
        user = User.where(email: email).first
        if !user
          Rails.logger.warn "bounced email '#{email}'could not be found"
          next
        end
        user.bounce_count += 1
        user.last_bounce_at = Time.now
        user.save!
      end
    end

    complaint = message['complaint']
    if complaint
      complainedRecipients = complaint['complainedRecipients']
      if !complainedRecipients
        raise "parse error"
      end

      complainedRecipients.each do |complainedRecipients|

        email = complainedRecipients['emailAddress']
          
        user = User.where("lower(email) = lower(?)", email).first
        if !user
          Rails.logger.warn "bounced email '#{email}'could not be found"
          next
        end
        user.bounce_count += 1
        user.last_bounce_at = Time.now
        user.save!
      end
    end

    if !bounce && !complaint
        raise "parse error"
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

