namespace :mail do
  task friend_updates: [:environment] do
    if Date.today.wday == 1
      FriendUpdatesMailer.send_all
    else
      puts "not monday, skipping"
    end
  end
end
