# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::Roles', type: :request do
  let(:user) { create(:user) }
  let!(:role) { create(:role) }

  before { sign_in_user(user) }

  describe 'GET /admin/roles' do
    it 'returns a successful response' do
      get admin_roles_path
      expect(response).to have_http_status(:success)
    end

    it 'displays roles' do
      get admin_roles_path
      expect(response.body).to include(role.name)
    end

    context 'when not authenticated' do
      before { sign_out_user }

      it 'redirects to login' do
        get admin_roles_path
        expect(response).to redirect_to(new_admin_magic_link_path)
      end
    end
  end

  describe 'GET /admin/roles/new' do
    it 'returns a successful response' do
      get new_admin_role_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST /admin/roles' do
    let(:valid_params) { { role: { name: 'New Role' } } }
    let(:invalid_params) { { role: { name: '' } } }

    context 'with valid params' do
      it 'creates a new role' do
        expect {
          post admin_roles_path, params: valid_params
        }.to change(Role, :count).by(1)
      end

      it 'assigns position automatically' do
        post admin_roles_path, params: valid_params
        expect(Role.last.position).to be_present
      end

      it 'redirects to roles index' do
        post admin_roles_path, params: valid_params
        expect(response).to redirect_to(admin_roles_path)
      end
    end

    context 'with invalid params' do
      it 'does not create a role' do
        expect {
          post admin_roles_path, params: invalid_params
        }.not_to change(Role, :count)
      end

      it 'returns unprocessable entity' do
        post admin_roles_path, params: invalid_params
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context 'with duplicate name' do
      it 'does not create a role' do
        expect {
          post admin_roles_path, params: { role: { name: role.name } }
        }.not_to change(Role, :count)
      end
    end
  end

  describe 'GET /admin/roles/:id/edit' do
    it 'returns a successful response' do
      get edit_admin_role_path(role)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH /admin/roles/:id' do
    let(:valid_params) { { role: { name: 'Updated Role Name' } } }
    let(:invalid_params) { { role: { name: '' } } }

    context 'with valid params' do
      it 'updates the role' do
        patch admin_role_path(role), params: valid_params
        role.reload
        expect(role.name).to eq('Updated Role Name')
      end

      it 'redirects to roles index' do
        patch admin_role_path(role), params: valid_params
        expect(response).to redirect_to(admin_roles_path)
      end
    end

    context 'with invalid params' do
      it 'returns unprocessable entity' do
        patch admin_role_path(role), params: invalid_params
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe 'DELETE /admin/roles/:id' do
    context 'when role has no dependencies' do
      it 'deletes the role' do
        expect {
          delete admin_role_path(role)
        }.to change(Role, :count).by(-1)
      end

      it 'redirects to index' do
        delete admin_role_path(role)
        expect(response).to redirect_to(admin_roles_path)
      end
    end

    context 'when role has crew members' do
      before { create(:crew_member, role: role) }

      it 'does not delete the role' do
        expect {
          delete admin_role_path(role)
        }.not_to change(Role, :count)
      end

      it 'shows error message' do
        delete admin_role_path(role)
        expect(flash[:alert]).to be_present
      end
    end
  end
end
