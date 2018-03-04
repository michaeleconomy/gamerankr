class Search::GameRankrElasticSearch
  def self.for(query_string, options = {})
    page = (options[:page] || 1).to_i
    query =
      options[:autocomplete] ?
        autocomplete_search(query_string) : basic_search(query_string)
    response = Game.search(query).page(page)
    records = response.records
    games = Game.where(id: records.collect(&:id)).
      includes(:publishers, :ports => [:platform, :additional_data])
    
    WillPaginate::Collection.create(page, 10, [records.total, 10 * 10].min) do |pager|
      pager.replace(games)
    end
  end

  def self.basic_search(query)
    {
      query: {
        function_score: {
          query: {
            match: {
              title: {
                query: query,
                operator: "and"
              }
            }
          },
          field_value_factor: {
            field: :rankings_count,
            modifier: :log1p,
            factor: 0.5
          }
        }
      }
    }
  end

  def self.autocomplete_search(query)
    {
      query: {
        function_score: {
          query: {
            prefix: {
              title: query
            }
          },
          field_value_factor: {
            field: :rankings_count,
            modifier: :log1p,
            factor: 0.5
          }
        }
      }
    }
  end
end

