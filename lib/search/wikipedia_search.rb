class WikipediaSearch::Search
  def self.for(query, options = {})
    # https://github.com/christianhellsten/wikipedia-client
    
    # todo may want to look at this: http://www.labnol.org/internet/tools/using-wikipedia-api-demo-source-code-example/3076/
    
    p = Wikipedia.find query
    unless p.content
      #NOTE: captitalizing all the words helps alot!
      return nil
    end
    
    info_box = p.content[/\{\{Infobox VG(.*?)\}\}/m]
    if infobox =~ /Infobox VG series/
      logger.info "don't know how to handle a series yet"
      return 
    end
    
    p.image_urls
  end
  
end