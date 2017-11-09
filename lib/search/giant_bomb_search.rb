class Search::GiantBombSearch
  
  include HTTParty
  base_uri 'https://www.giantbomb.com/'

  def self.for(query, options = {})
    page = (options[:page] || 1).to_i
    Rails.logger.info "doing giantbomb search for #{query}, #{options.inspect}"

	response = get('/api/search/',
      :query => {
        :query => query,
        :resources => "game",
        :field_list => "site_detail_url,deck,id,image,platforms," + "
        	expected_release_day,expected_release_month,expected_release_year," +
        	"expected_release_quarter,name,original_release_date",
        :format => 'json',
        :page => page,
        :api_key => Secret['giant_bomb_api_key']
        })

  	Rails.logger.info "response.body: #{response.body}"

  	# pagination stuff
  	parsed_response = JSON.parse(response.body)
  	offset = parsed_response["offset"]
  	total_items = parsed_response["number_of_page_results"]
  	page_size = parsed_response["limit"]
  	current_page = (offset / page_size) + 1


  	results = parsed_response["results"].collect {|r| parse_item(r)}
  	
    WillPaginate::Collection.create(current_page, page_size, total_items) do |pager|
      pager.replace(results)
    end
  end

  private

  def self.parse_item(result)

    new_port = GiantBombPort.new(
      :url => result["site_detail_url"],
      :giant_bomb_id => result["id"],
      :small_image_url => get_image_code(result),
      :description => result["deck"])

    raise "TODO"
  end

  def self.get_image_code(result)
  	raise "TODO"
  end

end

