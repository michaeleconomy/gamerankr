class ShelfRecordLoader < GraphQL::Batch::Loader

  def perform(ranking_ids)
    rs = RankingShelf.where(ranking_id: ranking_ids).includes(:shelf).group_by(&:ranking_id)

    rs.each do |ranking_id, ranking_shelves|
      fulfill(ranking_id, ranking_shelves.collect(&:shelf))
    end
    ranking_ids.each { |id| fulfill(id, []) unless fulfilled?(id) }
  end
end