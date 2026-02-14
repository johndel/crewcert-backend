# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::Certificates', type: :request do
  let(:user) { create(:user) }
  let(:crew_member) { create(:crew_member) }
  let(:certificate_type) { create(:certificate_type) }
  let!(:certificate) { create(:certificate, crew_member: crew_member, certificate_type: certificate_type) }

  before { sign_in_user(user) }

  describe 'GET /admin/certificates' do
    it 'returns a successful response' do
      get admin_certificates_path
      expect(response).to have_http_status(:success)
    end

    it 'displays certificates' do
      get admin_certificates_path
      expect(response.body).to include(certificate_type.code)
    end

    context 'with status filter' do
      let!(:pending) { create(:certificate, status: 'pending') }
      let!(:verified) { create(:certificate, :verified) }

      it 'filters by pending status' do
        get admin_certificates_path, params: { filter: 'pending' }
        expect(response.body).to include(pending.certificate_type.code)
      end

      it 'filters by verified status' do
        get admin_certificates_path, params: { filter: 'verified' }
        expect(response.body).to include(verified.certificate_type.code)
      end
    end

    context 'with expiring filter' do
      let!(:expiring) { create(:certificate, :verified, :expiring_soon) }
      let!(:not_expiring) { create(:certificate, :verified, expiry_date: 1.year.from_now) }

      it 'filters expiring certificates' do
        get admin_certificates_path, params: { filter: 'expiring' }
        expect(response.body).to include(expiring.certificate_type.code)
      end
    end

    context 'with expired filter' do
      let!(:expired) { create(:certificate, :verified, :expired) }

      it 'filters expired certificates' do
        get admin_certificates_path, params: { filter: 'expired' }
        expect(response.body).to include(expired.certificate_type.code)
      end
    end

    context 'when not authenticated' do
      before { sign_out_user }

      it 'redirects to login' do
        get admin_certificates_path
        expect(response).to redirect_to(new_admin_magic_link_path)
      end
    end
  end

  describe 'GET /admin/certificates/:id' do
    it 'returns a successful response' do
      get admin_certificate_path(certificate)
      expect(response).to have_http_status(:success)
    end

    it 'displays certificate details' do
      get admin_certificate_path(certificate)
      expect(response.body).to include(certificate_type.code)
      expect(response.body).to include(crew_member.full_name)
    end

    context 'when certificate does not exist' do
      it 'returns not found' do
        get admin_certificate_path(id: 999999)
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe 'GET /admin/certificates/new' do
    it 'returns a successful response' do
      get new_admin_certificate_path
      expect(response).to have_http_status(:success)
    end

    context 'with crew_member_id param' do
      it 'preselects the crew member' do
        get new_admin_certificate_path, params: { crew_member_id: crew_member.id }
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe 'POST /admin/certificates' do
    let(:valid_params) do
      {
        certificate: {
          crew_member_id: crew_member.id,
          certificate_type_id: certificate_type.id,
          issue_date: 1.year.ago.to_date,
          expiry_date: 4.years.from_now.to_date,
          certificate_number: 'CERT-123'
        }
      }
    end

    let(:invalid_params) do
      { certificate: { crew_member_id: nil, certificate_type_id: nil } }
    end

    context 'with valid params' do
      it 'creates a new certificate' do
        expect {
          post admin_certificates_path, params: valid_params
        }.to change(Certificate, :count).by(1)
      end

      it 'sets status to pending' do
        post admin_certificates_path, params: valid_params
        expect(Certificate.last.status).to eq('pending')
      end

      it 'redirects to the certificate' do
        post admin_certificates_path, params: valid_params
        expect(response).to redirect_to(admin_certificate_path(Certificate.last))
      end
    end

    context 'with invalid params' do
      it 'does not create a certificate' do
        expect {
          post admin_certificates_path, params: invalid_params
        }.not_to change(Certificate, :count)
      end

      it 'returns unprocessable entity' do
        post admin_certificates_path, params: invalid_params
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context 'with invalid date range' do
      it 'does not create when expiry before issue' do
        invalid_dates = valid_params.deep_dup
        invalid_dates[:certificate][:issue_date] = Date.current
        invalid_dates[:certificate][:expiry_date] = 1.year.ago.to_date

        expect {
          post admin_certificates_path, params: invalid_dates
        }.not_to change(Certificate, :count)
      end
    end
  end

  describe 'GET /admin/certificates/:id/edit' do
    it 'returns a successful response' do
      get edit_admin_certificate_path(certificate)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH /admin/certificates/:id' do
    let(:valid_params) { { certificate: { certificate_number: 'UPDATED-123' } } }

    context 'with valid params' do
      it 'updates the certificate' do
        patch admin_certificate_path(certificate), params: valid_params
        certificate.reload
        expect(certificate.certificate_number).to eq('UPDATED-123')
      end

      it 'redirects to the certificate' do
        patch admin_certificate_path(certificate), params: valid_params
        expect(response).to redirect_to(admin_certificate_path(certificate))
      end
    end
  end

  describe 'DELETE /admin/certificates/:id' do
    it 'deletes the certificate' do
      expect {
        delete admin_certificate_path(certificate)
      }.to change(Certificate, :count).by(-1)
    end

    it 'redirects to crew member page' do
      delete admin_certificate_path(certificate)
      expect(response).to redirect_to(admin_crew_member_path(crew_member))
    end
  end

  describe 'POST /admin/certificates/:id/verify' do
    let(:pending_certificate) { create(:certificate, status: 'pending') }

    it 'verifies the certificate' do
      post verify_admin_certificate_path(pending_certificate)
      pending_certificate.reload
      expect(pending_certificate.status).to eq('verified')
    end

    it 'sets verified_by to current user' do
      post verify_admin_certificate_path(pending_certificate)
      pending_certificate.reload
      expect(pending_certificate.verified_by).to eq(user)
    end

    it 'sets verified_at' do
      post verify_admin_certificate_path(pending_certificate)
      pending_certificate.reload
      expect(pending_certificate.verified_at).to be_present
    end

    it 'redirects to pending certificates' do
      post verify_admin_certificate_path(pending_certificate)
      expect(response).to redirect_to(admin_certificates_path(filter: 'pending'))
    end

    context 'when certificate is already verified' do
      let(:verified_certificate) { create(:certificate, :verified) }

      it 'redirects with error' do
        post verify_admin_certificate_path(verified_certificate)
        expect(flash[:alert]).to be_present
      end
    end
  end

  describe 'POST /admin/certificates/:id/reject' do
    let(:pending_certificate) { create(:certificate, status: 'pending') }

    it 'rejects the certificate' do
      post reject_admin_certificate_path(pending_certificate), params: { rejection_reason: 'Invalid document' }
      pending_certificate.reload
      expect(pending_certificate.status).to eq('rejected')
    end

    it 'sets rejection reason' do
      post reject_admin_certificate_path(pending_certificate), params: { rejection_reason: 'Invalid document' }
      pending_certificate.reload
      expect(pending_certificate.rejection_reason).to eq('Invalid document')
    end

    it 'sets verified_by to current user' do
      post reject_admin_certificate_path(pending_certificate), params: { rejection_reason: 'Invalid' }
      pending_certificate.reload
      expect(pending_certificate.verified_by).to eq(user)
    end

    it 'redirects to pending certificates' do
      post reject_admin_certificate_path(pending_certificate), params: { rejection_reason: 'Invalid' }
      expect(response).to redirect_to(admin_certificates_path(filter: 'pending'))
    end
  end
end
