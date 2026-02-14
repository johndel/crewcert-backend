# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::CrewMembers', type: :request do
  let(:user) { create(:user) }
  let(:vessel) { create(:vessel) }
  let(:role) { create(:role) }
  let!(:crew_member) { create(:crew_member, vessel: vessel, role: role) }

  before { sign_in_user(user) }

  describe 'GET /admin/crew_members' do
    it 'returns a successful response' do
      get admin_crew_members_path
      expect(response).to have_http_status(:success)
    end

    it 'displays crew members' do
      get admin_crew_members_path
      expect(response.body).to include(crew_member.first_name)
    end

    context 'with search query' do
      let!(:john) { create(:crew_member, first_name: 'John', last_name: 'Smith') }
      let!(:jane) { create(:crew_member, first_name: 'Jane', last_name: 'Doe') }

      it 'filters by name' do
        get admin_crew_members_path, params: { q: { first_name_or_last_name_or_email_cont: 'John' } }
        expect(response.body).to include('John')
        expect(response.body).not_to include('Jane')
      end

      it 'filters by email' do
        get admin_crew_members_path, params: { q: { first_name_or_last_name_or_email_cont: john.email } }
        expect(response.body).to include('John')
      end
    end

    context 'with vessel filter' do
      let(:other_vessel) { create(:vessel) }
      let!(:other_crew) { create(:crew_member, vessel: other_vessel) }

      it 'filters by vessel' do
        get admin_crew_members_path, params: { q: { vessel_id_eq: vessel.id } }
        expect(response.body).to include(crew_member.first_name)
        expect(response.body).not_to include(other_crew.first_name)
      end
    end

    context 'when not authenticated' do
      before { sign_out_user }

      it 'redirects to login' do
        get admin_crew_members_path
        expect(response).to redirect_to(new_admin_magic_link_path)
      end
    end
  end

  describe 'GET /admin/crew_members/:id' do
    it 'returns a successful response' do
      get admin_crew_member_path(crew_member)
      expect(response).to have_http_status(:success)
    end

    it 'displays crew member details' do
      get admin_crew_member_path(crew_member)
      expect(response.body).to include(crew_member.full_name)
      expect(response.body).to include(crew_member.email)
    end

    context 'with certificates' do
      let!(:certificate) { create(:certificate, crew_member: crew_member) }

      it 'displays certificates' do
        get admin_crew_member_path(crew_member)
        expect(response.body).to include(certificate.certificate_type.code)
      end
    end

    context 'when crew member does not exist' do
      it 'returns not found' do
        get admin_crew_member_path(id: 999999)
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'GET /admin/crew_members/new' do
    it 'returns a successful response' do
      get new_admin_crew_member_path
      expect(response).to have_http_status(:success)
    end

    context 'with vessel_id param' do
      it 'preselects the vessel' do
        get new_admin_crew_member_path, params: { vessel_id: vessel.id }
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'POST /admin/crew_members' do
    let(:valid_params) do
      {
        crew_member: {
          first_name: 'New',
          last_name: 'Member',
          email: 'new.member@example.com',
          vessel_id: vessel.id,
          role_id: role.id
        }
      }
    end

    let(:invalid_params) do
      { crew_member: { first_name: '', last_name: '', email: '' } }
    end

    context 'with valid params' do
      it 'creates a new crew member' do
        expect {
          post admin_crew_members_path, params: valid_params
        }.to change(CrewMember, :count).by(1)
      end

      it 'redirects to the crew member' do
        post admin_crew_members_path, params: valid_params
        expect(response).to redirect_to(admin_crew_member_path(CrewMember.last))
      end
    end

    context 'with invalid params' do
      it 'does not create a crew member' do
        expect {
          post admin_crew_members_path, params: invalid_params
        }.not_to change(CrewMember, :count)
      end

      it 'returns unprocessable entity' do
        post admin_crew_members_path, params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'with duplicate email' do
      it 'does not create a crew member' do
        expect {
          post admin_crew_members_path, params: {
            crew_member: valid_params[:crew_member].merge(email: crew_member.email)
          }
        }.not_to change(CrewMember, :count)
      end
    end

    context 'with invalid email format' do
      it 'does not create a crew member' do
        expect {
          post admin_crew_members_path, params: {
            crew_member: valid_params[:crew_member].merge(email: 'invalid')
          }
        }.not_to change(CrewMember, :count)
      end
    end
  end

  describe 'GET /admin/crew_members/:id/edit' do
    it 'returns a successful response' do
      get edit_admin_crew_member_path(crew_member)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH /admin/crew_members/:id' do
    let(:valid_params) { { crew_member: { first_name: 'Updated' } } }
    let(:invalid_params) { { crew_member: { email: 'invalid' } } }

    context 'with valid params' do
      it 'updates the crew member' do
        patch admin_crew_member_path(crew_member), params: valid_params
        crew_member.reload
        expect(crew_member.first_name).to eq('Updated')
      end

      it 'redirects to the crew member' do
        patch admin_crew_member_path(crew_member), params: valid_params
        expect(response).to redirect_to(admin_crew_member_path(crew_member))
      end
    end

    context 'with invalid params' do
      it 'returns unprocessable entity' do
        patch admin_crew_member_path(crew_member), params: invalid_params
        expect(response).to have_http_status(:unprocessable_entity)
      end
    end
  end

  describe 'DELETE /admin/crew_members/:id' do
    it 'deletes the crew member' do
      expect {
        delete admin_crew_member_path(crew_member)
      }.to change(CrewMember, :count).by(-1)
    end

    it 'redirects to vessel page' do
      delete admin_crew_member_path(crew_member)
      expect(response).to redirect_to(admin_vessel_path(vessel))
    end

    context 'with associated certificates' do
      before { create(:certificate, crew_member: crew_member) }

      it 'deletes associated certificates' do
        expect {
          delete admin_crew_member_path(crew_member)
        }.to change(Certificate, :count).by(-1)
      end
    end
  end

  describe 'POST /admin/crew_members/:id/send_certificate_request' do
    it 'redirects to crew member page' do
      post send_certificate_request_admin_crew_member_path(crew_member)
      expect(response).to redirect_to(admin_crew_member_path(crew_member))
    end

    it 'creates a certificate request' do
      expect {
        post send_certificate_request_admin_crew_member_path(crew_member)
      }.to change(CertificateRequest, :count).by(1)
    end

    it 'sends an email' do
      expect {
        post send_certificate_request_admin_crew_member_path(crew_member)
      }.to have_enqueued_mail(CertificateRequestMailer, :request_certificates)
    end
  end
end
