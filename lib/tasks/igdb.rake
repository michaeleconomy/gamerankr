namespace :igdb do
  desc "send the friend updates email"
  task crawl: [:environment] do
    IgdbClient.crawl_games
  end
end
