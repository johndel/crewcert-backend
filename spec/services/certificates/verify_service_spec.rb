# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Certificates::VerifyService do
  let(:user) { create(:user) }
  let(:certificate) { create(:certificate, status: 'pending') }

  before do
    # Attach a document to the certificate
    certificate.document.attach(
      io: StringIO.new('fake pdf content'),
      filename: 'test.pdf',
      content_type: 'application/pdf'
    )
  end

  describe '.call' do
    context 'with valid certificate' do
      it 'returns success' do
        result = described_class.call(certificate: certificate, user: user)
        expect(result).to be_success
      end

      it 'changes status to verified' do
        described_class.call(certificate: certificate, user: user)
        certificate.reload
        expect(certificate.status).to eq('verified')
      end

      it 'sets verified_at' do
        freeze_time do
          described_class.call(certificate: certificate, user: user)
          certificate.reload
          expect(certificate.verified_at).to eq(Time.current)
        end
      end

      it 'sets verified_by to user' do
        described_class.call(certificate: certificate, user: user)
        certificate.reload
        expect(certificate.verified_by).to eq(user)
      end

      it 'returns the certificate in data' do
        result = described_class.call(certificate: certificate, user: user)
        expect(result.data).to eq(certificate)
      end
    end

    context 'with notes' do
      it 'accepts verification notes' do
        result = described_class.call(certificate: certificate, user: user, notes: 'All documents verified')
        expect(result).to be_success
      end
    end

    context 'with already verified certificate' do
      let(:verified_certificate) { create(:certificate, :verified) }

      before do
        verified_certificate.document.attach(
          io: StringIO.new('fake pdf content'),
          filename: 'test.pdf',
          content_type: 'application/pdf'
        )
      end

      it 'returns failure' do
        result = described_class.call(certificate: verified_certificate, user: user)
        expect(result).to be_failure
      end

      it 'includes error message' do
        result = described_class.call(certificate: verified_certificate, user: user)
        expect(result.error).to include('cannot')
      end
    end

    context 'with rejected certificate' do
      let(:rejected_certificate) { create(:certificate, :rejected) }

      before do
        rejected_certificate.document.attach(
          io: StringIO.new('fake pdf content'),
          filename: 'test.pdf',
          content_type: 'application/pdf'
        )
      end

      it 'returns failure' do
        result = described_class.call(certificate: rejected_certificate, user: user)
        expect(result).to be_failure
      end
    end

    context 'with processing certificate' do
      let(:processing_certificate) { create(:certificate, status: 'processing') }

      before do
        processing_certificate.document.attach(
          io: StringIO.new('fake pdf content'),
          filename: 'test.pdf',
          content_type: 'application/pdf'
        )
      end

      it 'returns success' do
        result = described_class.call(certificate: processing_certificate, user: user)
        expect(result).to be_success
      end
    end

    context 'without attached document' do
      let(:certificate_no_doc) { create(:certificate, status: 'pending') }

      it 'returns failure' do
        result = described_class.call(certificate: certificate_no_doc, user: user)
        expect(result).to be_failure
      end

      it 'includes error about document' do
        result = described_class.call(certificate: certificate_no_doc, user: user)
        expect(result.error).to include('Document')
      end
    end
  end
end
