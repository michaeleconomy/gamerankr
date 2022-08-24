namespace :mail do
  desc "send the friend updates email"
  task friend_updates: [:environment] do
    if Date.today.wday == 1
      puts "sending friend updates"
      FriendUpdatesMailer.send_all
    else
      puts "not monday, skipping"
    end
  end
end
