require 'test_helper'

class BounceControllerTest < ActionDispatch::IntegrationTest

  test "bounce" do
    u = create :user
    assert !u.email_bounced?

    message = {
      Message: {
        bounce: {
          bouncedRecipients: [{emailAddress: u.email}]
        }
      }.to_json
    }.to_json

    post bounce_bounce_url, params: message
    assert_response 200

    u.reload

    assert u.email_bounced?
  end

  test "complaint" do
    u = create :user
    assert !u.email_bounced?

    message = {
      Message: {
        complaint: {
          complainedRecipients: [{emailAddress: u.email}]
        }
      }.to_json
    }.to_json

    post bounce_bounce_url, params: message
    assert_response 200

    u.reload

    assert u.email_bounced?
  end
end