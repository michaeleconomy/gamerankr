require 'test_helper'

class AuthControllerTest < ActionDispatch::IntegrationTest
  test "sign_in" do
    get sign_in_path
    assert_response 200

    password = "foo"
    u = create(:user, password: password)

    post sign_in_path, params: { email: u.email, password: password}
    assert_response 302

    assert_signed_in
  end

  test "sign_in show - already signed in" do
    sign_in
    get sign_in_path
    assert_response 302
  end

  test "sign_in post - already signed in" do
    sign_in
    post sign_in_path
    assert_response 302
  end

  test "sign_in bad password" do
    get sign_in_path
    assert_response 200

    password = "foo"
    u = create(:user, password: password)

    post sign_in_path, params: { email: u.email, password: password + "x"}
    assert_response 200

    assert_signed_out
  end

  test "sign_in unverified" do
    get sign_in_path
    assert_response 200

    password = "foo"
    u = create(:user, password: password, verified_at: nil, verification_code: "boo")

    post sign_in_path, params: { email: u.email, password: password}
    assert_redirected_to verification_required_url

    assert_signed_out
  end

  test "sign_out" do
    sign_in
    assert_signed_in

    get sign_out_path
    assert_response 200

    post sign_out_path
    assert_response 302

    assert_signed_out
  end

  test "create_account" do
    get create_account_path

    assert User.count == 0


    assert_emails 1 do
      post create_account_path,
        params: {email: "foo@foo.com", password: "foo", real_name: "foo man"}
    end

    assert_response 302


    assert User.count == 1

    u = User.first

    assert !u.verified?
  end

  test "create_account dup email" do
    other = create :user

    assert User.count == 1
    post create_account_path,
      params: {email: other.email, password: "fooooo", real_name: "machoman randy savage"}
    assert_response 200

    assert User.count == 1
  end


  test "create_account show - already signed in" do
    sign_in
    get create_account_path
    assert_response 302
  end

  test "create_account post - already signed in" do
    sign_in
    post create_account_path
    assert_response 302
  end


  test "verification_required" do
    assert User.count == 0
    get create_account_path
    post create_account_path,
      params: {email: "foo@foo.com", password: "foo", real_name: "foo man"}
    assert User.count == 1

    get verification_required_path
    assert_response 200
    u = User.first
    assert u.verification_code != nil
    assert !u.verified?
  end

  test 'resend verification' do

    assert_emails 1 do
      post create_account_path,
        params: {email: "foo@foo.com", password: "foo", real_name: "foo man"}
    end
    assert_emails 1 do
      post resend_verification_email_path
    end
    assert_response 302
    
  end


  test "verification_required redirects when signed in" do
    sign_in

    get verification_required_path
    assert_response 302
  end

  test "verify" do

    assert User.count == 0
    get create_account_path
    post create_account_path,
      params: {email: "foo@foo.com", password: "foo", real_name: "foo man"}
    assert User.count == 1

    u = User.first
    assert u.verification_code != nil
    get verify_url(code: u.verification_code)
    assert_response 302

    u.reload
    assert u.verified?
    assert u.verification_code == nil
    assert_signed_in
  end


  test "bad verify" do

    assert User.count == 0
    get create_account_path
    post create_account_path,
      params: {email: "foo@foo.com", password: "foo", real_name: "foo man"}
    assert User.count == 1

    u = User.first
    assert u.verification_code != nil
    get verify_url(code: u.verification_code + "x")
    assert_response 302

    u.reload
    assert !u.verified?
    assert u.verification_code != nil

    assert_signed_out
  end


  test "reset_password_request" do
    u = create :user

    assert u.password_reset_request == nil

    get reset_password_request_url
    assert_response 200

    assert_emails 1 do
      post reset_password_request_url,
        params: {email: u.email}
    end
    assert_response 302

    u.reload
    assert u.password_reset_request != nil

  end

  test "reset_password_request bad email" do
    u = create :user

    get reset_password_request_url
    assert_response 200

    assert_emails 0 do
      post reset_password_request_url,
        params: {email: u.email + "x"}
    end
    assert_response 200

    u.reload
    assert u.password_reset_request == nil
  end

  test "reset_password" do
    u = create :user
    post reset_password_request_url,
            params: {email: u.email}
    r = u.password_reset_request

    assert r != nil

    get reset_password_url code: r.code
    assert_response 200

    assert !u.authenticate("foosool")

    post reset_password_url,
      params: {code: r.code, password:"foosool", password_confirm: "foosool"}

    assert_response 302
    assert_signed_in

    u.reload

    assert u.authenticate("foosool")
  end


  test "reset_password no code" do
    u = create :user
    get reset_password_url
    assert_response 302
  end

  test "reset_password bad code" do
    u = create :user
    get reset_password_url code: "foo"
    assert_response 302
  end


  test "reset_password expired code" do
    u = create :user
    post reset_password_request_url,
      params: {email: u.email}
    r = u.password_reset_request

    assert r != nil
    r.updated_at = 3.days.ago
    r.save!

    get reset_password_url code: r.code
    assert_response 302
  end


  test "web token auto sign in" do
    sign_in(web: true)

    #clear session
    cookies[Gamerankr::Application.config.session_options[:key]] = nil

    get updates_url
    assert_response 200

    assert_select "a", "Sign Out"
  end

  test "welcome" do
    sign_in

    get welcome_url
    assert_response 200
  end

  test "deleted user test" do
    u = sign_in
    assert_signed_in

    u.destroy

    get "/"
    assert_response 302

    assert_signed_out
  end

end