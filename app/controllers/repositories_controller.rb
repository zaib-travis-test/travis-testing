class RepositoriesController < ApplicationController
	PER_PAGE = 100

  def index
		fetch_and_paginate_data if params[:search].present?
  end

  private

  def fetch_and_paginate_data
  	set_api_limitation_message
  	@repositories = call_github_api(params[:search], params[:page])
		@paginated_data = @repositories.paginate(per_page: PER_PAGE)
		dummy_array = Array.new(@total_entries.to_i)
		@collection_size_objects = dummy_array.paginate(page: params[:page], per_page: PER_PAGE)
  end

  def set_api_limitation_message
  	# This limitaiton is set by the Github. For more info read: https://docs.github.com/v3/search/
  	if params[:page].to_i > 20
			params[:page] = 20
			@message = 'Only the first 1000 search results are available. For more info read: https://docs.github.com/v3/search/'
		end
  end

  def call_github_api(query, page)
  	http_call = URI.open("https://api.github.com/search/repositories?q=#{query}&per_page=#{PER_PAGE}&page=#{page}").read
		parsed_respone = JSON.parse(http_call)
		response = parsed_respone.with_indifferent_access
		@total_entries = response[:total_count]
		response[:items]
  end
end
