class RecordLoader < GraphQL::Batch::Loader
  def initialize(model, column_name = :id)
    @model = model
    @column_name = column_name
  end

  def perform(ids)
    @model.where(@column_name => ids).each { |record| fulfill(record[@column_name], record) }
    ids.each { |id| fulfill(id, nil) unless fulfilled?(id) }
  end
end