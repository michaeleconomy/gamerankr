class Types::MutationType < Types::BaseObject
  graphql_name "Mutation"

  field :rank_port, Types::RankingType, null: false do
    argument :port_id, ID, required: true
    argument :ranking, Int
    argument :remove_ranking, Boolean
    argument :review, String
    argument :add_shelf_id, ID
    argument :remove_shelf_id, ID
  end

  def rank_port(port_id:, ranking:, remove_ranking:, review:, add_shelf_id:, remove_shelf_id:)
    user = context[:current_user]
    port = Port.find(port_id)
    ranking_object = user.rankings.where(game_id: port.game_id).first
    if !ranking_object
      ranking_object = user.rankings.new
      ranking_object.game = port.game
    end
    ranking_object.port = port
    if ranking
      ranking_object.ranking = ranking
    end

    if remove_ranking
      ranking_object.ranking = nil
    end

    if review
      ranking_object[:review] = review
    end

    if add_shelf_id
      ranking_object.ranking_shelves.find_or_initialize_by(shelf_id: add_shelf_id)
    elsif !ranking_object.id?
      #TODO - this will break for custom shlelves/localization
      default_shelf = user.shelves.find_by_name("Played")
      if !default_shelf
        raise "no default shelf could be found"
      end
      ranking_object.ranking_shelves.new(shelf_id: default_shelf.id)
    end
    ranking_object.save!

    if remove_shelf_id
      rs = ranking_object.ranking_shelves.where(shelf_id: remove_shelf_id).first
      if rs
        rs.destroy
      end
    end

    ranking_object
  end


  field :destroy_ranking, Types::RankingType, null: false do
    argument :port_id, ID, required: true
  end
  def destroy_ranking(port_id:)
    ranking = context[:current_user].rankings.where(port_id: port_id).first
    if !ranking
      raise ActiveRecord::RecordNotFound.new("couldn't find ranking for port id #{port_id}")
    end
    ranking.destroy!
    ranking
  end


  field :comment, Types::CommentType, null: false do
    argument :resource_type, String, required: true
    argument :resource_id,  ID, required: true
    argument :comment, String, required: true
  end

  def comment(resource_type:, resource_id:, comment:)
    context[:current_user].comments.
      create!(resource_id: resource_id,
        resource_type: resource_type,
        comment: comment)
  end


  field :destroy_comment, Types::CommentType, null: false do
    argument :id, ID, required: true
  end

  def destroy_comment(id:)
    user = context[:current_user]
    comment = user.comments.where(id: id).first
    if !comment
      raise ActiveRecord::RecordNotFound.new(
        "couldn't find comment for id #{id} belonging to #{user.id}")
    end

    comment.destroy!
    comment
  end

  field :flag, Boolean, null: false do
    argument :text, String
    argument :resource_id, ID, required: true
    argument :resource_type, String, required: true
  end

  def flag(text:, resource_id:, resource_type:)
    type = FlaggedItem.get_type(args[:resource_type])
    resource = type && args[:resource_id] && type.find(args[:resource_id].to_i)
    user = ctx[:signed_in] && ctx[:current_user]
    FlagEmailJob.perform_async(user && user.id,
      args[:resource_id], args[:resource_type], args[:text])
    true
  end
end
