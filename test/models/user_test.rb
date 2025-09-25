require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(
      email_address: "test@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  test "should be valid with valid attributes" do
    assert @user.valid?
  end

  test "should require email_address" do
    @user.email_address = nil
    assert_not @user.valid?
  end

  test "should normalize email_address to lowercase" do
    @user.email_address = "TEST@EXAMPLE.COM"
    @user.save
    assert_equal "test@example.com", @user.email_address
  end

  test "should strip whitespace from email_address" do
    @user.email_address = "  test@example.com  "
    @user.save
    assert_equal "test@example.com", @user.email_address
  end

  test "should require password" do
    @user.password = nil
    assert_not @user.valid?
  end

  test "should require password confirmation" do
    @user.password_confirmation = nil
    assert_not @user.valid?
  end

  test "should require password confirmation to match password" do
    @user.password_confirmation = "different_password"
    assert_not @user.valid?
  end

  test "should have secure password" do
    @user.save
    assert_not_nil @user.password_digest
    assert @user.authenticate("password123")
    assert_not @user.authenticate("wrong_password")
  end

  test "should have many sessions" do
    @user.save
    session1 = @user.sessions.build
    session2 = @user.sessions.build

    assert_difference '@user.sessions.count', 2 do
      @user.save
    end
  end

  test "should destroy dependent sessions when user is destroyed" do
    @user.save
    session = @user.sessions.create!

    assert_difference 'Session.count', -1 do
      @user.destroy
    end
  end

  test "should save successfully" do
    assert_difference 'User.count', 1 do
      @user.save
    end

    saved_user = User.last
    assert_equal "test@example.com", saved_user.email_address
    assert saved_user.authenticate("password123")
  end
end
