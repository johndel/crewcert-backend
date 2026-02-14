# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::Matrix', type: :request do
  let(:user) { create(:user) }
  let!(:vessel) { create(:vessel) }
  let!(:role) { create(:role) }
  let!(:certificate_type) { create(:certificate_type) }

  before { sign_in_user(user) }

  describe 'GET /admin/matrix' do
    it 'returns a successful response' do
      get admin_matrix_index_path
      expect(response).to have_http_status(:success)
    end

    it 'displays vessels' do
      get admin_matrix_index_path
      expect(response.body).to include(vessel.name)
    end

    it 'displays roles' do
      get admin_matrix_index_path
      expect(response.body).to include(role.name)
    end

    it 'displays certificate types' do
      get admin_matrix_index_path
      expect(response.body).to include(certificate_type.code)
    end

    context 'with vessel filter' do
      let!(:other_vessel) { create(:vessel) }

      it 'filters by vessel' do
        get admin_matrix_index_path, params: { vessel_id: vessel.id }
        expect(response).to have_http_status(:success)
      end
    end

    context 'with existing requirements' do
      let!(:requirement) do
        create(:matrix_requirement, vessel: vessel, role: role, certificate_type: certificate_type)
      end

      it 'displays requirements' do
        get admin_matrix_index_path
        expect(response).to have_http_status(:success)
      end
    end

    context 'when not authenticated' do
      before { sign_out_user }

      it 'redirects to login' do
        get admin_matrix_index_path
        expect(response).to redirect_to(new_admin_magic_link_path)
      end
    end
  end

  describe 'PATCH /admin/matrix/update_requirement' do
    context 'when creating a new requirement' do
      let(:params) do
        {
          vessel_id: vessel.id,
          role_id: role.id,
          certificate_type_id: certificate_type.id,
          level: 'M'
        }
      end

      it 'creates a matrix requirement' do
        expect {
          patch update_requirement_admin_matrix_index_path, params: params
        }.to change(MatrixRequirement, :count).by(1)
      end

      it 'sets requirement level' do
        patch update_requirement_admin_matrix_index_path, params: params
        requirement = MatrixRequirement.last
        expect(requirement.mandatory?).to be true
      end

      context 'with turbo_stream format' do
        it 'returns turbo stream response' do
          patch update_requirement_admin_matrix_index_path, params: params, as: :turbo_stream
          expect(response.media_type).to eq('text/vnd.turbo-stream.html')
        end
      end
    end

    context 'when removing a requirement' do
      let!(:requirement) do
        create(:matrix_requirement, vessel: vessel, role: role, certificate_type: certificate_type)
      end

      let(:params) do
        {
          vessel_id: vessel.id,
          role_id: role.id,
          certificate_type_id: certificate_type.id,
          level: 'none'
        }
      end

      it 'removes the requirement' do
        expect {
          patch update_requirement_admin_matrix_index_path, params: params
        }.to change(MatrixRequirement, :count).by(-1)
      end
    end

    context 'when updating requirement level' do
      let!(:requirement) do
        create(:matrix_requirement, :optional, vessel: vessel, role: role, certificate_type: certificate_type)
      end

      let(:params) do
        {
          vessel_id: vessel.id,
          role_id: role.id,
          certificate_type_id: certificate_type.id,
          level: 'M'
        }
      end

      it 'updates the requirement level' do
        patch update_requirement_admin_matrix_index_path, params: params
        requirement.reload
        expect(requirement.mandatory?).to be true
      end
    end
  end
end
