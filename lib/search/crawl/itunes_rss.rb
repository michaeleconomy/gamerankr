class Search::Crawl::ItunesRss
  include HTTParty
  base_uri 'rss.itunes.apple.com'

  ENDPOINTS =
    %w(/api/v1/us/ios-apps/top-paid/games/100/explicit.json
    /api/v1/us/ios-apps/top-paid/games/100/non-explicit.json
    /api/v1/us/ios-apps/new-games-we-love/all/100/explicit.json
    /api/v1/us/ios-apps/new-games-we-love/all/100/non-explicit.json
    /api/v1/us/ios-apps/top-free/games/100/non-explicit.json
    /api/v1/us/ios-apps/top-free/games/100/explicit.json
    /api/v1/us/ios-apps/top-free-ipad/all/100/non-explicit.json
    /api/v1/us/ios-apps/top-free-ipad/all/100/explicit.json
    /api/v1/us/ios-apps/top-grossing/all/100/non-explicit.json
    /api/v1/us/ios-apps/top-grossing/all/100/explicit.json
    /api/v1/us/ios-apps/top-grossing-ipad/all/100/non-explicit.json
    /api/v1/us/ios-apps/top-grossing-ipad/all/100/explicit.json)

  def self.crawl
    titles = []
    ENDPOINTS.each do |endpoint|
      response = get(endpoint)
      json = JSON.parse(response.body)
      results = json["feed"]["results"]
      titles += results.collect do |result|
        result["name"]
      end
      sleep 2
    end
    titles.each do |title|
      Search::ItunesSearch.for(title, :limit => 100)
      sleep 2
    end
    nil
  end
end


# {"feed":
#   {
#     "title":"Top Paid iPhone Apps",
#     "id":"https://rss.itunes.apple.com/api/v1/us/ios-apps/top-paid/games/1/explicit.json",
#     "author":{"name":"iTunes Store","uri":"http://wwww.apple.com/us/itunes/"},
#     "links":[
#       {"self":"https://rss.itunes.apple.com/api/v1/us/ios-apps/top-paid/games/1/explicit.json"},
#       {"alternate":"https://itunes.apple.com/WebObjects/MZStore.woa/wa/viewTop?genreId=6014\u0026popId=30"}
#     ],
#     "copyright":"Copyright © 2018 Apple Inc. All rights reserved.",
#     "country":"us",
#     "icon":"http://itunes.apple.com/favicon.ico",
#     "updated":"2018-05-26T07:31:11.000-07:00",
#     "results":[
#       {"artistName":"Warner Bros.","id":"623592465","releaseDate":"2013-05-02","name":"Heads Up!","kind":"iosSoftware","copyright":"© 2013 Telepictures Productions Inc.","artistId":"298372283","artistUrl":"https://itunes.apple.com/us/developer/warner-bros/id298372283?mt=8","artworkUrl100":"https://is3-ssl.mzstatic.com/image/thumb/Purple118/v4/33/38/45/33384524-c01d-a463-4f88-f2e6cb29ea5f/AppIcon-1x_U007emarketing-85-220-6.png/200x200bb.png","genres":[{"genreId":"6014","name":"Games","url":"https://itunes.apple.com/us/genre/id6014"},{"genreId":"6016","name":"Entertainment","url":"https://itunes.apple.com/us/genre/id6016"},{"genreId":"7019","name":"Word","url":"https://itunes.apple.com/us/genre/id7019"},{"genreId":"7005","name":"Card","url":"https://itunes.apple.com/us/genre/id7005"}],"url":"https://itunes.apple.com/us/app/heads-up/id623592465?mt=8"}
#     ]
#   }
# }