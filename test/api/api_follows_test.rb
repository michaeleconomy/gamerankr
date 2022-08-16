require 'test_helper'

class ApiFollowsTest < ActionDispatch::IntegrationTest

  test "get following empty" do
    u = create :user
    sign_in_api
    query = <<-GRAPHQL
      query Following($userId: ID!, $after: String) {
        user(id: $userId) {
          __typename
          following(first: 30, after: $after) {
            __typename
            edges {
              __typename
              user: node {
                __typename
                ...UserBasic
              }
            }
            pageInfo {
              __typename
              endCursor
              hasNextPage
            }
          }
        }
      }
      fragment UserBasic on User {
        __typename
        id
        real_name
        photo_url
      }
    GRAPHQL
    result = api_execute_graphql query, variables: { userId: u.id }
    assert result['data']['user']['following']['edges'].empty?
  end

  test "get following some" do
    u = create :user
    u2 = create :user
    u.followings.create! following_id: u2.id

    assert Follow.count == 1

    sign_in_api
    query = <<-GRAPHQL
      query Following($userId: ID!, $after: String) {
        user(id: $userId) {
          __typename
          following(first: 30, after: $after) {
            __typename
            edges {
              __typename
              user: node {
                __typename
                ...UserBasic
              }
            }
            pageInfo {
              __typename
              endCursor
              hasNextPage
            }
          }
        }
      }
      fragment UserBasic on User {
        __typename
        id
        real_name
        photo_url
      }
    GRAPHQL
    result = api_execute_graphql query, variables: { userId: u.id }
    follows = result['data']['user']['following']['edges']
    assert follows.size == 1
    assert follows[0]['user']['id'] == u2.id.to_s
  end
end