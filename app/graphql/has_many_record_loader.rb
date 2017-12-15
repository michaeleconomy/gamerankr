class HasManyRecordLoader < GraphQL::Batch::Loader
  def initialize(model, column_name)
    @model = model
    @column_name = column_name
  end

  def perform(ids)
    @model.where(@column_name => ids).group_by(&@column_name).each { |key, records| fulfill(key, records) }
    ids.each { |id| fulfill(id, nil) unless fulfilled?(id) }
  end
end