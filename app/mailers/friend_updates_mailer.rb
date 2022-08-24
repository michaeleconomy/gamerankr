class FriendUpdatesMailer < ApplicationMailer

  UPDATE_PERIOD = 7.days

  def self.send_all(date = Date.today)
    all_updates =
      Ranking.where("updated_at >= ? and updated_at < ?", date - UPDATE_PERIOD, date).
      includes(:game, :shelves,
        {user: :facebook_user, port: [:platform, :additional_data]}).
      group_by(&:user_id)
    puts "got all rankings"
    User.order(:id).pluck(:id).each do |user_id|
      u = User.find(user_id)
      unless u.recieves_emails? && u.friend_update_email
        puts "not sending to #{u.id} emails off" 
        next
      end
      updates = 
        all_updates.values_at(*u.following_user_ids).flatten.compact[0..100]
      if updates.empty?
        puts "not sending to #{u.id} no updates" 
        next
      end
      puts "not sending to #{u.id}" 
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
    subject = "GameRankr updates from #{friends.to_sentence} for #{@date_str}"
    mail(to: to_user.email, subject: subject)
  end
end