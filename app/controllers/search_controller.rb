class SearchController < ApplicationController
  
  def search
    @query = params[:query]
    unless @query.blank?
      begin
        @results = Search::AmazonSearch.for(@query, :page => params[:page])
      rescue Amazon::RequestError => e
        @error = e
      end
      get_rankings(@results)
    end
  end
end
