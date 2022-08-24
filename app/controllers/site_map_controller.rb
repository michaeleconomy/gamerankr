class SiteMapController < ApplicationController
  MAX_PER_PAGE = 50000

  def index
    @game_pages = (Game.count / MAX_PER_PAGE) + 1
    @user_pages = (User.count / MAX_PER_PAGE) + 1
    @shelf_pages = (Shelf.where("ranking_shelves_count> 0").count / MAX_PER_PAGE) + 1
    @platform_pages = (Platform.count / MAX_PER_PAGE) + 1
    @manufacturer_pages = (Manufacturer.count / MAX_PER_PAGE) + 1
    @ranking_pages = (Ranking.count / MAX_PER_PAGE) + 1
  end

  def games
    page = params[:page].to_i
    @games = Game.order(:id).where("rankings_count > 0").
      limit(MAX_PER_PAGE).
      offset(MAX_PER_PAGE * (page - 1)).
      includes(:rankings).
      group("games.id").
      pluck(:id, :title, "max(rankings.created_at) as last_review")
  end

  def users
    page = params[:page].to_i
    @users = User.order(:id).
      where("rankings_count > 0").
      limit(MAX_PER_PAGE).
      offset(MAX_PER_PAGE * (page - 1)).
      includes(:rankings).
      group("users.id").
      pluck(:id, :real_name, "max(rankings.created_at) as last_review")
  end

  def shelves
    page = params[:page].to_i
    @shelves = Shelf.where("ranking_shelves_count> 0").
      order(:id).
      limit(MAX_PER_PAGE).
      offset(MAX_PER_PAGE * (page - 1)).
      includes(:ranking_shelves).
      group("shelves.id").
      pluck(:id, :name,  "max(ranking_shelves.created_at) as last_review")
  end

  def platforms
    page = params[:page].to_i
    @platforms = Platform.order(:id).
      limit(MAX_PER_PAGE).
      offset(MAX_PER_PAGE * (page - 1)).
      pluck(:id, :name)
  end

  def manufacturers
    page = params[:page].to_i
    @manufacturers = Manufacturer.order(:id).
      limit(MAX_PER_PAGE).
      offset(MAX_PER_PAGE * (page - 1)).
      pluck(:id, :name)
  end

  def rankings
    page = params[:page].to_i
    @rankings = Ranking.order(:id).limit(MAX_PER_PAGE).offset(MAX_PER_PAGE * (page - 1)).pluck(:id)
  end

  def misc
  end

end