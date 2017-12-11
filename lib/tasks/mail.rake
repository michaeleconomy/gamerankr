namespace :mail do
  task friend_updates: [:environment] do
    FriendUpdatesMailer.send_all
  end
end
