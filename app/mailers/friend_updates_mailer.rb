class FriendUpdatesMailer < ApplicationMailer

  UPDATE_PERIOD = 7.days

  def self.send_all(date = Date.today)
    all_updates =
      Ranking.where("updated_at >= ? and updated_at < ?", date - UPDATE_PERIOD, date).
      includes(:game, :shelves,
        {:user => :facebook_user, :port => [:platform, :additional_data]}).
      group_by(&:user_id)
    User.order(:id).pluck(:id).each do |user_id|
      u = User.find(user_id)
      next unless u.friend_update_email #ignore users who have opted out
      next unless u.email #ignore users w/o email addresses
      updates = 
        all_updates.values_at(*u.following_user_ids).flatten.compact[0..100]
      next if updates.empty?
      updates(u, updates, date).deliver
    end
  end

  def updates(to_user, updates, date)
    @to_user = to_user
    @updates = updates
    @updates.sort_by!{|u| - u.updated_at.to_i}
    @currently_playing_shelf = @to_user.shelves.where(name: "Currently Playing").first
    @currently_playing = []
    if @currently_playing_shelf
      @currently_playing = @currently_playing_shelf.rankings.limit(5).includes(:game)
    end

    friends = updates.collect{|u| u.user.first_name}.uniq
    if friends.size > 3
      friends = friends[0..2]
      friends << "more"
    end

    @email_pref = :friend_update_email
    @date_str = "#{date.strftime("%A %B")} #{date.day.ordinalize}, #{date.year}"
    subject = "GameRankr friend updates from #{friends.to_sentence} for #{@date_str}"
    mail(:to => to_user.email, :subject => subject)
  end
end