# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::CertificateTypes', type: :request do
  let(:user) { create(:user) }
  let!(:certificate_type) { create(:certificate_type) }

  before { sign_in_user(user) }

  describe 'GET /admin/certificate_types' do
    it 'returns a successful response' do
      get admin_certificate_types_path
      expect(response).to have_http_status(:success)
    end

    it 'displays certificate types' do
      get admin_certificate_types_path
      expect(response.body).to include(certificate_type.code)
    end

    context 'with search query' do
      let!(:stcw) { create(:certificate_type, code: 'STCW-VI-1', name: 'Basic Safety Training') }
      let!(:medical) { create(:certificate_type, code: 'MED-01', name: 'Medical Certificate') }

      it 'filters by code' do
        get admin_certificate_types_path, params: { q: { code_or_name_cont: 'STCW' } }
        expect(response.body).to include('STCW-VI-1')
        expect(response.body).not_to include('MED-01')
      end

      it 'filters by name' do
        get admin_certificate_types_path, params: { q: { code_or_name_cont: 'Medical' } }
        expect(response.body).to include('MED-01')
      end
    end

    context 'when not authenticated' do
      before { sign_out_user }

      it 'redirects to login' do
        get admin_certificate_types_path
        expect(response).to redirect_to(new_admin_magic_link_path)
      end
    end
  end

  describe 'GET /admin/certificate_types/new' do
    it 'returns a successful response' do
      get new_admin_certificate_type_path
      expect(response).to have_http_status(:success)
    end
  end

  describe 'POST /admin/certificate_types' do
    let(:valid_params) do
      {
        certificate_type: {
          code: 'NEW-CERT',
          name: 'New Certificate Type',
          validity_period_months: 60
        }
      }
    end

    let(:invalid_params) { { certificate_type: { code: '', name: '' } } }

    context 'with valid params' do
      it 'creates a new certificate type' do
        expect {
          post admin_certificate_types_path, params: valid_params
        }.to change(CertificateType, :count).by(1)
      end

      it 'redirects to index' do
        post admin_certificate_types_path, params: valid_params
        expect(response).to redirect_to(admin_certificate_types_path)
      end
    end

    context 'with invalid params' do
      it 'does not create a certificate type' do
        expect {
          post admin_certificate_types_path, params: invalid_params
        }.not_to change(CertificateType, :count)
      end

      it 'returns unprocessable entity' do
        post admin_certificate_types_path, params: invalid_params
        expect(response).to have_http_status(:unprocessable_content)
      end
    end

    context 'with duplicate code' do
      it 'does not create a certificate type' do
        expect {
          post admin_certificate_types_path, params: {
            certificate_type: { code: certificate_type.code, name: 'Other Name' }
          }
        }.not_to change(CertificateType, :count)
      end
    end

    context 'with invalid code format' do
      it 'does not create a certificate type' do
        expect {
          post admin_certificate_types_path, params: {
            certificate_type: { code: 'invalid code!', name: 'Test' }
          }
        }.not_to change(CertificateType, :count)
      end
    end
  end

  describe 'GET /admin/certificate_types/:id/edit' do
    it 'returns a successful response' do
      get edit_admin_certificate_type_path(certificate_type)
      expect(response).to have_http_status(:success)
    end
  end

  describe 'PATCH /admin/certificate_types/:id' do
    let(:valid_params) { { certificate_type: { name: 'Updated Name' } } }
    let(:invalid_params) { { certificate_type: { code: '' } } }

    context 'with valid params' do
      it 'updates the certificate type' do
        patch admin_certificate_type_path(certificate_type), params: valid_params
        certificate_type.reload
        expect(certificate_type.name).to eq('Updated Name')
      end

      it 'redirects to index' do
        patch admin_certificate_type_path(certificate_type), params: valid_params
        expect(response).to redirect_to(admin_certificate_types_path)
      end
    end

    context 'with invalid params' do
      it 'returns unprocessable entity' do
        patch admin_certificate_type_path(certificate_type), params: invalid_params
        expect(response).to have_http_status(:unprocessable_content)
      end
    end
  end

  describe 'DELETE /admin/certificate_types/:id' do
    context 'when certificate type has no dependencies' do
      it 'deletes the certificate type' do
        expect {
          delete admin_certificate_type_path(certificate_type)
        }.to change(CertificateType, :count).by(-1)
      end

      it 'redirects to index' do
        delete admin_certificate_type_path(certificate_type)
        expect(response).to redirect_to(admin_certificate_types_path)
      end
    end

    context 'when certificate type has certificates' do
      before { create(:certificate, certificate_type: certificate_type) }

      it 'does not delete the certificate type' do
        expect {
          delete admin_certificate_type_path(certificate_type)
        }.not_to change(CertificateType, :count)
      end

      it 'shows error message' do
        delete admin_certificate_type_path(certificate_type)
        expect(flash[:alert]).to be_present
      end
    end
  end
end
