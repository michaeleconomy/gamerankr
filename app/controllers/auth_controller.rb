class AuthController < ApplicationController
  before_action :require_sign_in, :except => [
  	:sign_in, :reset_password, :do_sign_in, :do_reset_password]

  def sign_in
  	flash[:error] = "Function unavailable."
  	redirect_to "/"
  end

  def do_sign_in
  	flash[:error] = "Function unavailable."
  	redirect_to "/"
  end

  def sign_out
  end

  def do_sign_out
  	session[:user_id] = nil
  	flash[:error] = "Signed Out."
  	redirect_to "/"
  end

  def reset_password
  	flash[:error] = "Function unavailable."
  	redirect_to "/"
  end

  def do_reset_password
  	flash[:error] = "Function unavailable."
  	redirect_to "/"
  end
end
