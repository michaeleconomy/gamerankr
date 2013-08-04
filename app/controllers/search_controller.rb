class SearchController < ApplicationController
  
  
  def search
    @query = params[:query]
    
    @sources = {
      'amazon' => Search::AmazonSearch,
      'itunes' => Search::ItunesSearch,
      'android marketplace' => Search::AndroidMarketplaceSearch,
      'steam' => Search::SteamSearch}
    @source = @sources[params[:search_source]] ? params[:search_source] : 'amazon'
    
    unless @query.blank?
      begin
        @results = @sources[@source].for(@query, :page => params[:page])
      rescue Amazon::RequestError => e
        @error = e
      end
      get_rankings(@results)
    end
  end
end
