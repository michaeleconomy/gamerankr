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

  test "signed_in game view" do
    user = sign_in_api

    r = create_ranking user: user

    query = <<-GRAPHQL
      query Game($id: ID!) {
        game(id: $id) {
          __typename
          ...GameBasic
          ports {
            __typename
            id
            medium_image_url
            description
          }

          rankings(first: 30) {
            __typename
            edges {
              __typename
              node {
                __typename
                ...RankingWithUser
              }
            }
            pageInfo {
              __typename
              endCursor
              hasNextPage
            }
          }
          friend_rankings {
            __typename
            ...RankingWithUser
          }
        }
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
      fragment RankingWithUser on Ranking {
        __typename
        ...RankingBasic
        user {
          __typename
          ...UserBasic
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
      fragment UserBasic on User {
        __typename
        id
        real_name
        photo_url
      }
    GRAPHQL
    result = execute_query(query, variables: { id: r.game_id })
    # puts result.inspect

    assert result['data']['game']['title'] = r.game.title
    assert result['data']['game']['friend_rankings'].is_a?(Array)
    assert result['data']['game']['rankings']['edges'].is_a?(Array)
    assert result['data']['game']['rankings']['edges'].size == 1
  end

  test "mobile login create" do
    assert User.count == 0
    assert Authorization.count == 0

    get login_url(fb_auth_token: "ffff")
    assert_response 200

    assert User.count == 1
    assert Authorization.count == 2
  end


  test "mobile login sign_in" do
    u = create :user
    Authorization.create!(provider: "facebook", uid: 5, user_id: u.id)

    assert User.count == 1
    assert Authorization.count == 1

    get login_url(fb_auth_token: "ffff")
    
    assert User.count == 1
    assert Authorization.count == 2
  end


  private

  def execute_query(query, variables: nil)
    headers = {}
    if @api_token
      headers["api-token"] = @api_token
    end
    post graphql_path,
      params: {query: query, variables: variables},
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