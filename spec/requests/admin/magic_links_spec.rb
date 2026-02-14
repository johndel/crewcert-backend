# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::MagicLinks', type: :request do
  let!(:user) { create(:user) }

  describe 'GET /admin/magic_links/new' do
    it 'returns a successful response' do
      get new_admin_magic_link_path
      expect(response).to have_http_status(:success)
    end

    it 'displays the login form' do
      get new_admin_magic_link_path
      expect(response.body).to include('email')
    end

    context 'when already authenticated' do
      before { sign_in_user(user) }

      it 'redirects to admin root' do
        get new_admin_magic_link_path
        expect(response).to redirect_to(admin_root_path)
      end
    end
  end

  describe 'POST /admin/magic_links' do
    context 'with valid email' do
      it 'sends magic link email' do
        expect {
          post admin_magic_links_path, params: { email: user.email }
        }.to have_enqueued_mail(UserMailer, :magic_link)
      end

      it 'redirects with success message' do
        post admin_magic_links_path, params: { email: user.email }
        expect(response).to redirect_to(new_admin_magic_link_path)
        expect(flash[:notice]).to be_present
      end
    end

    context 'with non-existent email' do
      it 'does not send email' do
        expect {
          post admin_magic_links_path, params: { email: 'nonexistent@example.com' }
        }.not_to have_enqueued_mail(UserMailer, :magic_link)
      end

      it 'still shows success message (prevents enumeration)' do
        post admin_magic_links_path, params: { email: 'nonexistent@example.com' }
        expect(response).to redirect_to(new_admin_magic_link_path)
        expect(flash[:notice]).to be_present
      end
    end

    context 'with blank email' do
      it 'does not send email' do
        expect {
          post admin_magic_links_path, params: { email: '' }
        }.not_to have_enqueued_mail(UserMailer, :magic_link)
      end
    end

    context 'with uppercase email' do
      it 'finds user case-insensitively' do
        expect {
          post admin_magic_links_path, params: { email: user.email.upcase }
        }.to have_enqueued_mail(UserMailer, :magic_link)
      end
    end

    context 'with whitespace in email' do
      it 'trims whitespace' do
        expect {
          post admin_magic_links_path, params: { email: "  #{user.email}  " }
        }.to have_enqueued_mail(UserMailer, :magic_link)
      end
    end

    context 'when already authenticated' do
      before { sign_in_user(user) }

      it 'redirects to admin root' do
        post admin_magic_links_path, params: { email: user.email }
        expect(response).to redirect_to(admin_root_path)
      end
    end
  end

  describe 'GET /admin/magic_links/verify/:token' do
    context 'with valid token' do
      let(:token) { user.generate_token_for(:magic_link) }

      it 'signs in the user' do
        get admin_verify_magic_link_path(token: token)
        expect(response).to redirect_to(admin_root_path)
      end

      it 'sets flash notice' do
        get admin_verify_magic_link_path(token: token)
        expect(flash[:notice]).to include('signed in')
      end
    end

    context 'with invalid token' do
      it 'redirects to login page' do
        get admin_verify_magic_link_path(token: 'invalid-token')
        expect(response).to redirect_to(new_admin_magic_link_path)
      end

      it 'sets flash alert' do
        get admin_verify_magic_link_path(token: 'invalid-token')
        expect(flash[:alert]).to be_present
      end
    end

    context 'with expired token' do
      let(:token) do
        # Generate a token that's already expired
        travel_to 2.hours.ago do
          user.generate_token_for(:magic_link)
        end
      end

      it 'redirects to login page' do
        get admin_verify_magic_link_path(token: token)
        expect(response).to redirect_to(new_admin_magic_link_path)
      end

      it 'sets flash alert' do
        get admin_verify_magic_link_path(token: token)
        expect(flash[:alert]).to be_present
      end
    end

    context 'when already authenticated' do
      before { sign_in_user(user) }

      it 'redirects to admin root' do
        get admin_verify_magic_link_path(token: 'any-token')
        expect(response).to redirect_to(admin_root_path)
      end
    end
  end
end
