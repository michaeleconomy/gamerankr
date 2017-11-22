class Tasks::BulkSearcher

  include HTTParty
  base_uri 'http://www.gamerankr.com/'

	def self.search_giant_bomb_for_amazon_only_records_with_reviews
		titles = Port.where("additional_data_type = 'AmazonPort' and rankings_count != 0").
		  pluck(:title)
		titles.each do |title|
			response = get('/search/',
	      :query => {
	        :query => title.gsub(/\[.*\]/, ""),
	        :search_source => "giantbomb"
	        })
			puts "search"
			sleep 40
		end
	end
end