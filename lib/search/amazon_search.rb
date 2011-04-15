require 'pp'

class Search::AmazonSearch
  def self.for(query, options = {})
    page = (options[:page] || 1).to_i
    
    sorts = 'pmrank', 'salesrank', 'price', '-price', 'titlerank'
    sort = nil
    response = Amazon::Ecs.item_search(query,
      { :search_index => 'VideoGames',
        :response_group => "Medium",
        :sort => sort,
        :item_page => page})

    if response.has_error?
     raise response.error
    end
    
    results = []
    
    response.items.each do |item|
      puts "\n\n\nITEM"
      pp item
      result = {}
      # retrieve string value using XML path
      asin = item.get("asin")
      item_attrs = item / "itemattributes"
      upc = item_attrs.inner_html_at("upc")
      ean = item_attrs.inner_html_at("ean")
      
      old_port = Port.find_by_asin asin
      if old_port
        results << old_port
        next
      end
      # if !port || port.upc != upc
      #   port ||= port_by_upc = Port.find_by_upc upc
      # end
      # if !port || port.ean != ean
      #   port ||= port_by_ean = Port.find_by_ean ean
      # end
      # 
      # old_port = Port.merge_ports([port_by_isbn, port_by_upc, port_by_ean])
      
      price_str = item / "offersummary/lowestusedprice"
      price = price_str && price_str.inner_html_at("amount").to_i
      
      release_date_str = item_attrs.inner_html_at("releasedate")
      if release_date_str
        if release_date_str =~ /(\d{4})(-(\d{2})(-(\d{2}))?)?/
          year = $1
          month = $3
          day = $5
          released_at = Date.new(*[year,month,day].compact.collect(&:to_i))
          released_at_accuracy = day ? 'day' : (month ? 'month' : 'year')
        else
          puts "unrecognized year"
        end
      end
      
      platform_name = item_attrs.inner_html_at("platform")
      if !platform_name
        puts "skipping_item (no platform provided)"
        next
      end
      platform = Platform.find_or_initialize_by_name(platform_name)
      
      large_image = (item / "largeimage")
      if large_image
        large_image_url = large_image.inner_html_at("url")
      end
      
      description = nil
      reviews = item / "editorialreviews"
      
      if reviews
        reviews.each do |review|
          if (review / "source").inner_html == "Product Description"
            description = CGI.unescapeHTML((review / "content").inner_html)
            break
          end
        end
      end
      
      
      new_port = Port.new(
        :ean => ean,
        :upc => upc,
        :asin => asin,
        :amazon_image_url => large_image_url,
        :amazon_price => price,
        :title => CGI.unescapeHTML(item_attrs.inner_html_at("title")),
        :released_at => released_at,
        :released_at_accuracy => released_at_accuracy,
        :amazon_url => URI.unescape(item.get("detailpageurl")),
        :platform => platform,
        :amazon_updated_at => Time.now,
        :binding => item_attrs.inner_html_at("binding"),
        :brand => item_attrs.inner_html_at("brand"),
        :manufacturer => item_attrs.inner_html_at("manufacturer"),
        :amazon_description => description)
      
      if new_port.binding == "Accessory"
        puts "skipping item (Accessory): #{new_port}"
        next
      end
      
      if new_port.title =~ /Console|Game System|Bundle|Controller|Head Set|Xbox 360 Live|Gold Card|Sony Playstation Network/
        puts "skipping item (not a game): #{new_port.title}"
        next
      end
      
      game = Game.find_or_create_by_title(new_port.title)
      new_port.game = game
      
      developer_name = item_attrs.inner_html_at("studio")
      if developer_name
        developer = Developer.find_or_initialize_by_name(developer_name)
        
        unless game.developers.include?(developer)
          new_port.developers << developer
        end
      end
      
      
      publisher_name = item_attrs.inner_html_at("publisher")
      if publisher_name
        publisher = Publisher.find_or_initialize_by_name(publisher_name)
        new_port.publishers << publisher
      end
      
      
      new_port.save!
      
      results << new_port
    end
    
    
    WillPaginate::Collection.create(response.item_page, 10, response.total_results) do |pager|
      pager.replace(results)
    end
  end
end