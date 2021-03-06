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
    @games = Game.order(:id).limit(MAX_PER_PAGE).offset(MAX_PER_PAGE * (page - 1)).pluck(:id, :title)
  end

  def users
    page = params[:page].to_i
    @users = User.order(:id).limit(MAX_PER_PAGE).offset(MAX_PER_PAGE * (page - 1)).pluck(:id, :real_name)
  end

  def shelves
    page = params[:page].to_i
    @shelves = Shelf.where("ranking_shelves_count> 0").order(:id).limit(MAX_PER_PAGE).offset(MAX_PER_PAGE * (page - 1)).pluck(:id, :name)

  end

  def platforms
    page = params[:page].to_i
    @platforms = Platform.order(:id).limit(MAX_PER_PAGE).offset(MAX_PER_PAGE * (page - 1)).pluck(:id, :name)
  end

  def manufacturers
    page = params[:page].to_i
    @manufacturers = Manufacturer.order(:id).limit(MAX_PER_PAGE).offset(MAX_PER_PAGE * (page - 1)).pluck(:id, :name)
  end

  def rankings
    page = params[:page].to_i
    @rankings = Ranking.order(:id).limit(MAX_PER_PAGE).offset(MAX_PER_PAGE * (page - 1)).pluck(:id)
  end

  def misc
  end

end