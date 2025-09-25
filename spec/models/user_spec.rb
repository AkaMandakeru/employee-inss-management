require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    let(:user) { build(:user) }

    it 'is valid with valid attributes' do
      expect(user).to be_valid
    end

    describe 'email_address' do
      it 'is required' do
        user.email_address = nil
        expect(user).not_to be_valid
      end

      it 'is normalized to lowercase' do
        user.email_address = "TEST@EXAMPLE.COM"
        user.save!
        expect(user.email_address).to eq("test@example.com")
      end

      it 'strips whitespace' do
        user.email_address = "  test@example.com  "
        user.save!
        expect(user.email_address).to eq("test@example.com")
      end
    end

    describe 'password' do
      it 'is required' do
        user.password = nil
        expect(user).not_to be_valid
      end

      it 'accepts password confirmation' do
        user.password_confirmation = nil
        # has_secure_password doesn't require confirmation by default
        expect(user).to be_valid
      end

      it 'requires password confirmation to match password' do
        user.password_confirmation = "different_password"
        expect(user).not_to be_valid
      end
    end
  end

  describe 'secure password' do
    let(:user) { create(:user) }

    it 'has password digest' do
      expect(user.password_digest).not_to be_nil
    end

    it 'authenticates with correct password' do
      expect(user.authenticate("password123")).to eq(user)
    end

    it 'does not authenticate with wrong password' do
      expect(user.authenticate("wrong_password")).to be_falsey
    end
  end

  describe 'associations' do
    let(:user) { create(:user) }

    it 'has many sessions' do
      session1 = create(:session, user: user)
      session2 = create(:session, user: user)

      expect(user.sessions).to include(session1, session2)
      expect(user.sessions.count).to eq(2)
    end

    it 'destroys dependent sessions when user is destroyed' do
      session = create(:session, user: user)

      expect { user.destroy }.to change(Session, :count).by(-1)
    end
  end

  describe 'saving' do
    it 'saves successfully' do
      user = create(:user)

      expect(user.email_address).to match(/user\d+@example\.com/)
      expect(user.authenticate("password123")).to eq(user)
    end
  end

  describe 'factory' do
    it 'creates a valid user' do
      user = create(:user)
      expect(user).to be_valid
      expect(user).to be_persisted
    end

    it 'creates admin user with trait' do
      user = create(:user, :admin)
      expect(user.email_address).to eq("admin@example.com")
      expect(user.authenticate("admin123")).to eq(user)
    end

    it 'creates user with sessions using trait' do
      user = create(:user, :with_sessions)
      expect(user.sessions.count).to eq(1)
    end

    it 'generates unique email addresses' do
      user1 = create(:user)
      user2 = create(:user)

      expect(user1.email_address).not_to eq(user2.email_address)
    end
  end
end
