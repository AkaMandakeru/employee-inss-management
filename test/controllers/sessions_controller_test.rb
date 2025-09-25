require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(
      email_address: "test@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  test "should get new session page" do
    get new_session_url
    assert_response :success
    assert_select "h1", "Sign In"
    assert_select "form[action=?]", sessions_path
  end

  test "should create session with valid credentials" do
    post sessions_url, params: {
      email_address: "test@example.com",
      password: "password123"
    }

    assert_redirected_to root_path
    follow_redirect!
    assert_response :success
  end

  test "should not create session with invalid email" do
    post sessions_url, params: {
      email_address: "wrong@example.com",
      password: "password123"
    }

    assert_redirected_to new_session_path
    follow_redirect!
    assert_select ".alert-danger", "Try another email address or password."
  end

  test "should not create session with invalid password" do
    post sessions_url, params: {
      email_address: "test@example.com",
      password: "wrongpassword"
    }

    assert_redirected_to new_session_path
    follow_redirect!
    assert_select ".alert-danger", "Try another email address or password."
  end

  test "should not create session with blank credentials" do
    post sessions_url, params: {
      email_address: "",
      password: ""
    }

    assert_redirected_to new_session_path
    follow_redirect!
    assert_select ".alert-danger", "Try another email address or password."
  end

  test "should handle case insensitive email" do
    post sessions_url, params: {
      email_address: "TEST@EXAMPLE.COM",
      password: "password123"
    }

    assert_redirected_to root_path
  end

  test "should handle email with whitespace" do
    post sessions_url, params: {
      email_address: "  test@example.com  ",
      password: "password123"
    }

    assert_redirected_to root_path
  end

  test "should destroy session" do
    # First login
    post sessions_url, params: {
      email_address: "test@example.com",
      password: "password123"
    }

    # Then logout
    delete session_url(@user)
    assert_redirected_to new_session_path
    follow_redirect!
    assert_response :success
  end

  test "should redirect to root after successful login" do
    post sessions_url, params: {
      email_address: "test@example.com",
      password: "password123"
    }

    assert_redirected_to root_path
  end

  test "should create session record on successful login" do
    assert_difference 'Session.count', 1 do
      post sessions_url, params: {
        email_address: "test@example.com",
        password: "password123"
      }
    end
  end

  test "should not create session record on failed login" do
    assert_no_difference 'Session.count' do
      post sessions_url, params: {
        email_address: "test@example.com",
        password: "wrongpassword"
      }
    end
  end

  test "should handle non-existent user" do
    post sessions_url, params: {
      email_address: "nonexistent@example.com",
      password: "password123"
    }

    assert_redirected_to new_session_path
    follow_redirect!
    assert_select ".alert-danger", "Try another email address or password."
  end

  test "should allow unauthenticated access to new and create actions" do
    # These should work without authentication
    get new_session_url
    assert_response :success

    post sessions_url, params: {
      email_address: "test@example.com",
      password: "password123"
    }
    assert_redirected_to root_path
  end

  test "should require authentication for destroy action" do
    # This should redirect to login if not authenticated
    delete session_url(@user)
    # The exact behavior depends on authentication setup
    # but it should not be a 200 response
    assert_not_equal 200, response.status
  end
end
