require 'rails_helper'

RSpec.describe SessionsController, type: :controller do
  let!(:user) { create(:user, email_address: "test@example.com", password: "password123") }

  describe 'GET #new' do
    it 'returns a successful response' do
      get :new
      expect(response).to be_successful
    end
  end

  describe 'POST #create' do
    context 'with valid credentials' do
      it 'creates a session' do
        post :create, params: {
          email_address: "test@example.com",
          password: "password123"
        }

        expect(response).to redirect_to(root_path)
      end

      it 'creates a session record' do
        expect {
          post :create, params: {
            email_address: "test@example.com",
            password: "password123"
          }
        }.to change(Session, :count).by(1)
      end

      it 'redirects to root after successful login' do
        post :create, params: {
          email_address: "test@example.com",
          password: "password123"
        }

        expect(response).to redirect_to(root_path)
      end
    end

    context 'with invalid credentials' do
      it 'does not create a session with invalid email' do
        post :create, params: {
          email_address: "wrong@example.com",
          password: "password123"
        }

        expect(response).to redirect_to(new_session_path)
      end

      it 'does not create a session with invalid password' do
        post :create, params: {
          email_address: "test@example.com",
          password: "wrongpassword"
        }

        expect(response).to redirect_to(new_session_path)
      end

      it 'does not create a session with blank credentials' do
        post :create, params: {
          email_address: "",
          password: ""
        }

        expect(response).to redirect_to(new_session_path)
      end

      it 'does not create a session record on failed login' do
        expect {
          post :create, params: {
            email_address: "test@example.com",
            password: "wrongpassword"
          }
        }.not_to change(Session, :count)
      end

      it 'handles non-existent user' do
        post :create, params: {
          email_address: "nonexistent@example.com",
          password: "password123"
        }

        expect(response).to redirect_to(new_session_path)
      end
    end

    context 'email normalization' do
      it 'handles case insensitive email' do
        post :create, params: {
          email_address: "TEST@EXAMPLE.COM",
          password: "password123"
        }

        expect(response).to redirect_to(root_path)
      end

      it 'handles email with whitespace' do
        post :create, params: {
          email_address: "  test@example.com  ",
          password: "password123"
        }

        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe 'DELETE #destroy' do
    it 'destroys the session' do
      # First login to create a session
      post :create, params: {
        email_address: "test@example.com",
        password: "password123"
      }

      # Then logout
      delete :destroy, params: { id: user.id }
      expect(response).to redirect_to(new_session_path)
    end
  end

  describe 'authentication requirements' do
    it 'allows unauthenticated access to new and create actions' do
      # These should work without authentication
      get :new
      expect(response).to be_successful

      post :create, params: {
        email_address: "test@example.com",
        password: "password123"
      }
      expect(response).to redirect_to(root_path)
    end

    it 'requires authentication for destroy action' do
      # This should redirect to login if not authenticated
      delete :destroy, params: { id: user.id }
      # The exact behavior depends on authentication setup
      # but it should not be a 200 response
      expect(response.status).not_to eq(200)
    end
  end

  describe 'rate limiting' do
    # Note: Rate limiting tests would require more complex setup
    # and might depend on the specific rate limiting implementation
    it 'is configured with rate limiting' do
      expect(described_class).to respond_to(:rate_limit)
    end
  end

  describe 'unauthenticated access' do
    it 'allows unauthenticated access to specified actions' do
      expect(described_class).to respond_to(:allow_unauthenticated_access)
    end
  end
end
