require 'test_helper'

class ApiAuthTest < ActionDispatch::IntegrationTest
  test "create_account" do
    get create_account_path

    assert User.count == 0

    assert_emails 1 do
      post create_account_path(format: "json"),
        params: {email: "foo@foo.com", password: "foo", real_name: "foo man"}
    end

    assert_response 200


    assert User.count == 1

    u = User.first

    assert !u.verified?
  end

  test "create_account dup email" do
    other = create :user

    assert User.count == 1

    assert_emails 0 do
      post create_account_path(format: "json"),
        params: {email: other.email, password: "fooooo", real_name: "machoman randy savage"}
    end
    assert_response 400

    assert User.count == 1
  end

  test "create_account bad email" do
    assert User.count == 0
    post create_account_path(format: "json"),
      params: {email: "email.address", password: "fooooo", real_name: "machoman randy savage"}
    assert_response 400

    assert User.count == 0
  end

  test "create_account no pass" do
    assert User.count == 0
    post create_account_path(format: "json"),
      params: {email: "email.address", password: "", real_name: "machoman randy savage"}
    assert_response 400

    assert User.count == 0
  end


  test "sign in" do
    u = create :user, password: "f"
    assert_emails 0 do
      post login_url(format: "json"),
        params: {email: u.email, password: "f"}
    end
    assert_response 200
    r = JSON.parse(@response.body)

    assert r["current_user_id"] == u.id.to_s
    assert r["token"] != nil
  end


  test "sign in capitalized" do
    u = create :user, password: "f"
    assert_emails 0 do
      post login_url(format: "json"),
        params: {email: u.email.upcase, password: "f"}
    end
    assert_response 200
    r = JSON.parse(@response.body)

    assert r["current_user_id"] == u.id.to_s
    assert r["token"] != nil
  end

  test "sign in - bad email" do
    u = create :user, password: "f"
    assert_emails 0 do
      post login_url(format: "json"),
        params: {email: u.email + "f", password: "f"}
    end
    assert_response 404
    assert_signed_out
  end

  test "sign in - bad pass" do
    u = create :user, password: "f"
    assert_emails 0 do
      post login_url(format: "json"),
        params: {email: u.email, password: "ff"}
    end
    assert_response 400
    assert_signed_out
  end

  test "sign in - unverified" do
    u = create :user, password: "f", verified_at: nil, verification_code: "fff"
    assert_emails 1 do
      post login_url(format: "json"),
        params: {email: u.email, password: "f"}
    end
    r = JSON.parse(@response.body)

    assert r["current_user_id"] == nil
    assert r["token"] == nil
    assert r["unverified"] == "yes"
  end

  test "sign in - unverified - email disabled" do
    u = create :user, password: "f", verified_at: nil, verification_code: "fff"
    assert_emails 0 do
      post login_url(format: "json"),
        params: {email: u.email, password: "f", no_verify_email: false}
    end
    r = JSON.parse(@response.body)

    assert r["current_user_id"] == nil
    assert r["token"] == nil
    assert r["unverified"] == "yes"
  end


  test "resend_verification_email" do
    u = create :user, password: "f", verified_at: nil, verification_code: "fff"
    assert_emails 1 do
      post resend_verification_email_url(format: "json"),
        params: {email: u.email}
    end
    assert_response 200
  end

  test "resend_verification_email bad email" do
    assert_emails 0 do
      post resend_verification_email_url(format: "json"),
        params: {email: "xxx@booble.com"}
    end
    assert_response 404
  end



  test "reset_password_request" do
    u = create :user

    assert u.password_reset_request == nil

    get reset_password_request_url
    assert_response 200

    assert_emails 1 do
      post reset_password_request_url(format: "json"),
        params: {email: u.email}
    end
    assert_response 200

    u.reload
    assert u.password_reset_request != nil

  end

  test "reset_password_request bad email" do
    u = create :user

    get reset_password_request_url
    assert_response 200

    assert_emails 0 do
      post reset_password_request_url(format: "json"),
        params: {email: u.email + "x"}
    end
    assert_response 400

    u.reload
    assert u.password_reset_request == nil
  end


end