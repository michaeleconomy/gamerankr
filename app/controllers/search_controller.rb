class SearchController < ApplicationController
  
  
  def search
    @query = params[:query]
    
    @sources = {
      'gamerankr' => Search::GameRankrSearch,
      # 'gamerankr' => Search::GameRankrElasticSearch,
      # 'giantbomb' => Search::GiantBombSearch,
      # 'amazon' => Search::AmazonSearch,
      'itunes' => Search::ItunesSearch,
      # 'android marketplace' => Search::AndroidMarketplaceSearch,
      # 'steam' => Search::SteamSearch
    }
    @source = @sources[params[:search_source]] ? params[:search_source] : 'gamerankr'
    
    unless @query.blank?
      begin
        @results = @sources[@source].for(@query, page: params[:page])
        # if @results.empty? && @source == 'gamerankr' && @sources['giantbomb']
        #   Rails.logger.info "no local results - trying giantbomb"
        #   flash[:notice] = "No local results, attempting to search giant bomb instead"
        #   redirect_to search_url(query: @query, search_source: 'giantbomb')
        #   return
        # end
        Rails.logger.info "found #{@results.count} results for query: #{@query}"
      rescue JSON::ParserError => e
        @error = "invalid response from #{@source} partner api"
      # rescue Amazon::RequestError => e
      #   @error = e
      end
      get_rankings(@results)
    end
  end
end
