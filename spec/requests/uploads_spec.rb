# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Uploads', type: :request do
  let(:vessel) { create(:vessel) }
  let(:role) { create(:role) }
  let(:crew_member) { create(:crew_member, vessel: vessel, role: role) }
  let(:certificate_request) { create(:certificate_request, :sent, crew_member: crew_member) }
  let(:certificate_type) { create(:certificate_type) }

  before do
    create(:matrix_requirement, vessel: vessel, role: role, certificate_type: certificate_type)
  end

  describe 'GET /upload/:token' do
    context 'with valid token' do
      it 'returns a successful response' do
        get upload_path(token: certificate_request.token)
        expect(response).to have_http_status(:success)
      end

      it 'displays crew member name' do
        get upload_path(token: certificate_request.token)
        expect(response.body).to include(crew_member.full_name)
      end

      it 'displays required certificates' do
        get upload_path(token: certificate_request.token)
        expect(response.body).to include(certificate_type.code)
      end
    end

    context 'with invalid token' do
      it 'returns not found' do
        get upload_path(token: 'invalid-token')
        expect(response).to have_http_status(:not_found)
      end

      it 'displays invalid token message' do
        get upload_path(token: 'invalid-token')
        expect(response.body).to include('invalid')
      end
    end

    context 'with expired request' do
      let(:expired_request) { create(:certificate_request, :expired, crew_member: crew_member) }

      it 'returns gone status' do
        get upload_path(token: expired_request.token)
        expect(response).to have_http_status(:gone)
      end
    end

    context 'with already submitted request' do
      let(:submitted_request) { create(:certificate_request, :submitted, crew_member: crew_member) }

      it 'displays already submitted message' do
        get upload_path(token: submitted_request.token)
        expect(response.body).to include('submitted')
      end
    end
  end

  describe 'POST /upload/:token/upload_certificate' do
    let(:valid_params) do
      {
        certificate_type_id: certificate_type.id,
        certificate_number: 'CERT-123',
        issue_date: 1.year.ago.to_date,
        expiry_date: 4.years.from_now.to_date
      }
    end

    context 'with valid params' do
      it 'creates or updates a certificate' do
        expect {
          post upload_certificate_path(token: certificate_request.token), params: valid_params
        }.to change(Certificate, :count).by(1)
      end

      it 'sets status to pending' do
        post upload_certificate_path(token: certificate_request.token), params: valid_params
        expect(Certificate.last.status).to eq('pending')
      end

      context 'with turbo_stream format' do
        it 'returns turbo stream response' do
          post upload_certificate_path(token: certificate_request.token),
               params: valid_params,
               as: :turbo_stream
          expect(response.media_type).to eq('text/vnd.turbo-stream.html')
        end
      end
    end

    context 'with existing certificate' do
      let!(:existing) do
        create(:certificate, crew_member: crew_member, certificate_type: certificate_type)
      end

      it 'updates the existing certificate' do
        expect {
          post upload_certificate_path(token: certificate_request.token), params: valid_params
        }.not_to change(Certificate, :count)
      end

      it 'updates the certificate number' do
        post upload_certificate_path(token: certificate_request.token), params: valid_params
        existing.reload
        expect(existing.certificate_number).to eq('CERT-123')
      end
    end

    context 'with invalid params' do
      let(:invalid_params) do
        {
          certificate_type_id: certificate_type.id,
          issue_date: Date.current,
          expiry_date: 1.year.ago.to_date # expiry before issue
        }
      end

      it 'does not create a certificate' do
        expect {
          post upload_certificate_path(token: certificate_request.token), params: invalid_params
        }.not_to change(Certificate, :count)
      end
    end

    context 'with invalid token' do
      it 'returns not found' do
        post upload_certificate_path(token: 'invalid'), params: valid_params
        expect(response).to have_http_status(:not_found)
      end
    end

    context 'with certificate_type not in matrix' do
      let(:other_certificate_type) { create(:certificate_type, code: 'OTHER-001') }
      let(:unauthorized_params) do
        {
          certificate_type_id: other_certificate_type.id,
          certificate_number: 'CERT-456',
          issue_date: 1.year.ago.to_date,
          expiry_date: 4.years.from_now.to_date
        }
      end

      it 'returns forbidden status' do
        post upload_certificate_path(token: certificate_request.token), params: unauthorized_params
        expect(response).to have_http_status(:forbidden)
      end

      it 'does not create a certificate' do
        expect {
          post upload_certificate_path(token: certificate_request.token), params: unauthorized_params
        }.not_to change(Certificate, :count)
      end
    end

    context 'with expired request' do
      let(:expired_request) { create(:certificate_request, :expired, crew_member: crew_member) }

      it 'returns gone status' do
        post upload_certificate_path(token: expired_request.token), params: valid_params
        expect(response).to have_http_status(:gone)
      end
    end
  end

  describe 'POST /upload/:token (submit)' do
    context 'with valid token' do
      it 'submits the request' do
        post upload_path(token: certificate_request.token)
        certificate_request.reload
        expect(certificate_request.status).to eq('submitted')
      end

      it 'redirects to upload page' do
        post upload_path(token: certificate_request.token)
        expect(response).to redirect_to(upload_path(token: certificate_request.token))
      end

      it 'sets submitted_at' do
        post upload_path(token: certificate_request.token)
        certificate_request.reload
        expect(certificate_request.submitted_at).to be_present
      end
    end

    context 'with invalid token' do
      it 'returns not found' do
        post upload_path(token: 'invalid')
        expect(response).to have_http_status(:not_found)
      end
    end
  end
end
