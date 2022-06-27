class FollowerMailer < ApplicationMailer
  
  def follower(follow)
    @to_user = follow.following
    @follower = follow.follower
    if !@to_user || !@follower
      raise "FollowerMailer: to_user could not be found"
    end

    mail(:to => @to_user.email, :subject => "GameRankr: #{@follower.real_name} is now following you.")
  end
end
