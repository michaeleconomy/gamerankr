class SpamFiltersController < ApplicationController
  before_action :load_spam_filter, :only => [:destroy]
  before_action :require_admin
	def index
		@filters = SpamFilter.order("id desc").all
	end

	def create
		if !params[:spam_filter].is_a?(Hash) || !params[:spam_filter][:keyword].is_a?(String)
			flash[:error] = "Invalid parameters"
			redirect_to spam_filters_path
			return
		end

		SpamFilter.create(keyword: params[:spam_filter][:keyword])
		redirect_to spam_filters_path
	end

	def destroy
		@spam_filter.destroy
		redirect_to spam_filters_path
	end

end
