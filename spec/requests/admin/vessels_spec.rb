# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::Vessels', type: :request do
  let(:user) { create(:user) }
  let!(:vessel) { create(:vessel) }

  before { sign_in_user(user) }

  describe 'GET /admin/vessels' do
    it 'returns a successful response' do
      get admin_vessels_path
      expect(response).to have_http_status(:success)
    end

    it 'displays vessels' do
      get admin_vessels_path
      expect(response.body).to include(vessel.name)
    end

    context 'with search query' do
      let!(:target_vessel) { create(:vessel, name: 'Atlantic Explorer') }
      let!(:other_vessel) { create(:vessel, name: 'Pacific Dream') }

      it 'filters vessels by name' do
        get admin_vessels_path, params: { q: { name_or_imo_cont: 'Atlantic' } }
        expect(response.body).to include('Atlantic Explorer')
        expect(response.body).not_to include('Pacific Dream')
      end

      it 'filters vessels by IMO' do
        get admin_vessels_path, params: { q: { name_or_imo_cont: target_vessel.imo } }
        expect(response.body).to include('Atlantic Explorer')
      end
    end

    context 'when not authenticated' do
      before { sign_out_user }

      it 'redirects to login' do
        get admin_vessels_path
        expect(response).to redirect_to(new_admin_magic_link_path)
      end
    end
  end

  describe 'GET /admin/vessels/:id' do
    it 'returns a successful response' do
      get admin_vessel_path(vessel)
      expect(response).to have_http_status(:success)
    end

    it 'displays vessel details' do
      get admin_vessel_path(vessel)
      expect(response.body).to include(vessel.name)
    end

    context 'with crew members' do
      let!(:crew_member) { create(:crew_member, vessel: vessel) }

      it 'displays crew members' do
        get admin_vessel_path(vessel)
        expect(response.body).to include(crew_member.full_name)
      end
    end

    context 'when vessel does not exist' do
      it 'returns not found' do
        get admin_vessel_path(id: 999999)
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'GET /admin/vessels/new' do
    it 'returns a successful response' do
      get new_admin_vessel_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST /admin/vessels' do
    let(:valid_params) do
      { vessel: { name: 'New Vessel', imo: '1234567', management_company: 'Test Co' } }
    end

    let(:invalid_params) do
      { vessel: { name: '', imo: 'invalid' } }
    end

    context 'with valid params' do
      it 'creates a new vessel' do
        expect {
          post admin_vessels_path, params: valid_params
        }.to change(Vessel, :count).by(1)
      end

      it 'redirects to the vessel' do
        post admin_vessels_path, params: valid_params
        expect(response).to redirect_to(admin_vessel_path(Vessel.last))
      end

      it 'sets flash notice' do
        post admin_vessels_path, params: valid_params
        expect(flash[:notice]).to be_present
      end
    end

    context 'with invalid params' do
      it 'does not create a vessel' do
        expect {
          post admin_vessels_path, params: invalid_params
        }.not_to change(Vessel, :count)
      end

      it 'returns unprocessable entity' do
        post admin_vessels_path, params: invalid_params
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe 'GET /admin/vessels/:id/edit' do
    it 'returns a successful response' do
      get edit_admin_vessel_path(vessel)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH /admin/vessels/:id' do
    let(:valid_params) { { vessel: { name: 'Updated Name' } } }
    let(:invalid_params) { { vessel: { name: '' } } }

    context 'with valid params' do
      it 'updates the vessel' do
        patch admin_vessel_path(vessel), params: valid_params
        vessel.reload
        expect(vessel.name).to eq('Updated Name')
      end

      it 'redirects to the vessel' do
        patch admin_vessel_path(vessel), params: valid_params
        expect(response).to redirect_to(admin_vessel_path(vessel))
      end
    end

    context 'with invalid params' do
      it 'does not update the vessel' do
        original_name = vessel.name
        patch admin_vessel_path(vessel), params: invalid_params
        vessel.reload
        expect(vessel.name).to eq(original_name)
      end

      it 'returns unprocessable entity' do
        patch admin_vessel_path(vessel), params: invalid_params
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe 'DELETE /admin/vessels/:id' do
    it 'deletes the vessel' do
      expect {
        delete admin_vessel_path(vessel)
      }.to change(Vessel, :count).by(-1)
    end

    it 'redirects to index' do
      delete admin_vessel_path(vessel)
      expect(response).to redirect_to(admin_vessels_path)
    end

    context 'with associated crew members' do
      before { create(:crew_member, vessel: vessel) }

      it 'deletes associated crew members' do
        expect {
          delete admin_vessel_path(vessel)
        }.to change(CrewMember, :count).by(-1)
      end
    end
  end

  describe 'GET /admin/vessels/:id/readiness' do
    it 'returns a successful response' do
      get readiness_admin_vessel_path(vessel)
      expect(response).to have_http_status(:success)
    end

    context 'with crew members and requirements' do
      let(:role) { create(:role) }
      let(:cert_type) { create(:certificate_type) }
      let!(:crew_member) { create(:crew_member, vessel: vessel, role: role) }
      let!(:matrix_requirement) { create(:matrix_requirement, vessel: vessel, role: role, certificate_type: cert_type) }

      it 'displays compliance information' do
        get readiness_admin_vessel_path(vessel)
        expect(response.body).to include(CGI.escapeHTML(crew_member.full_name))
      end
    end
  end

  describe 'POST /admin/vessels/:id/request_all_certificates' do
    let(:role) { create(:role) }
    let!(:crew_member) { create(:crew_member, vessel: vessel, role: role) }

    it 'redirects to vessel page' do
      post request_all_certificates_admin_vessel_path(vessel)
      expect(response).to redirect_to(admin_vessel_path(vessel))
    end

    it 'creates certificate requests for crew members' do
      expect {
        post request_all_certificates_admin_vessel_path(vessel)
      }.to change(CertificateRequest, :count)
    end
  end
end
