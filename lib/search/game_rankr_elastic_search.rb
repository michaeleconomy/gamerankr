class Search::GameRankrElasticSearch
  def self.for(query, options = {})
    page = (options[:page] || 1).to_i
    response = Game.search(
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
    }).page(page)
    records = response.records
    games = Game.where(id: records.collect(&:id)).
      includes(:publishers, :ports => [:platform, :additional_data])
    
    WillPaginate::Collection.create(page, 10, [records.total, 10 * 10].min) do |pager|
      pager.replace(games)
    end
  end
end