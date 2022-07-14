require 'test_helper'

class ApiTest < ActionDispatch::IntegrationTest
	test "get popular games" do
	  query = <<-GRAPHQL
	    query popular{
	      popular_games {
	      	title
	      }
	    }
	  GRAPHQL
	  r = create_ranking

		result = execute_query(query)
		assert result['data'] != nil
		popular_games = result['data']['popular_games']
		assert popular_games.is_a?(Array)
		assert popular_games.size == 1
		
		assert popular_games[0]['title'] == r.game.title

	end

	test "signed out" do
	  query = <<-GRAPHQL
		  query Games {
			  my_games {
			    nodes {
			      id
			    }
			  }
			}
	  GRAPHQL
		result = execute_query(query)
		assert result['errors'][0]['message'] == "sign in required"
	end

	test "my games" do
		user = sign_in_api

		r = create_ranking user: user

	  query = <<-GRAPHQL
		  query Games {
			  my_games {
			    nodes {
			      id
			    }
			  }
			}
	  GRAPHQL
		result = execute_query(query)
		assert result['data']['my_games']['nodes'].size == 1
		assert result['data']['my_games']['nodes'][0]['id'] == r.id.to_s
	end

	test "my profile" do
		user = sign_in_api

		r = create_ranking user: user

	  query = <<-GRAPHQL
			query Me {
			  user: me {
			    __typename
			  	...UserDetail
			  }
			}
			fragment UserDetail on User {
			  __typename
			  ...UserBasic
			  rankings(first: 20) {
			    __typename
			    edges {
			      __typename
			      ranking: node {
			        __typename
			        ...RankingWithGame
			      }
			      
			   }
			    pageInfo {
			      __typename
			      endCursor
			      hasNextPage
			    }
			  }
			  shelves {
			    __typename
			    ...ShelfBasic
			  }
			}
			fragment UserBasic on User {
			  __typename
			  id
			  real_name
			  photo_url
			}
			fragment RankingWithGame on Ranking {
			  __typename
			  ...RankingBasic
			  game {
			    __typename
			    ...GameBasic
			  }
			}
			fragment RankingBasic on Ranking {
			  __typename
			  id
			  ranking
			  review
			  verb
			  comments_count
			  url
			  shelves {
			    __typename
			    ...ShelfBasic
			  }
			  port {
			    __typename
			    id
			    platform {
			      __typename
			      id
			      name
			    }
			    small_image_url
			  }
			}
			  
			fragment ShelfBasic on Shelf {
			  __typename
			  id
			  name
			}
			fragment GameBasic on Game {
			  __typename
			  id
			  title
			  url
			  ports {
			    __typename
			    id
			    platform {
			      __typename
			      id
			      name
			    }
			    small_image_url
			  }
			}
	  GRAPHQL
		result = execute_query(query)
		# puts result.inspect

		assert result['data']['user']['real_name'] == user.real_name
	end



	private

	def execute_query(query)
		headers = {}
		if @api_token
			headers["api-token"] = @api_token
		end
		post graphql_path,
			params: {query: query},
			headers: headers
		assert_response 200
		JSON.parse(@response.body)
	end

	def sign_in_api
		user = create :user

		@api_token = rand(2**512).to_s(36)
		ios_authorization = user.create_ios_authorization!(
        provider: 'gamerankr-ios',
        uid: user.id,
        token: @api_token)
		user
	end

end