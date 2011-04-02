class SearchController < ApplicationController
  
  def search
    @query = params[:query]
    @results = Search::AmazonSearch.for(@query, :page => params[:page])
    get_rankings(@results)
  end
end
