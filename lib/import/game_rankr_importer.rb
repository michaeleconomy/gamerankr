class Import::GameRankrImporter
  include HTTParty
  base_uri 'http://gamerankr.com'
  
  def self.lookup(query)
    sleep 0.1
    
    puts "making request for #{query}"
    response = get('/search',
      :query => {
        :query => query,
      })
    parsed_response = Nokogiri::HTML(response.body)
    next_link = parsed_response.css("a.next_page").first
    while next_link
      sleep 0.1
      url = next_link.attributes["href"].to_s
      
      puts "making request for #{url}"
      response = get(url)
      parsed_response = Nokogiri::HTML(response.body)
      next_link = parsed_response.css("a.next_page").first
    end
  rescue Timeout::Error
    puts "timeout,   sleeping then trying again"
    sleep 3
    retry
  end
  
  def self.import(file)
    titles = File.read(file).split("\n")
    platform = file.gsub "_", " "
    titles.each do |title|
      puts "looking up #{title}"
      lookup(title)
      lookup "#{title} #{platform}"
    end
  end
  
  def self.import_multi(files)
    files.each do |f|
      import(f)
    end
  end
end
