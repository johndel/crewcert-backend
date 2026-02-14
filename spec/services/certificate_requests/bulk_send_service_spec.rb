# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CertificateRequests::BulkSendService do
  let(:vessel) { create(:vessel) }
  let(:role) { create(:role) }
  let!(:crew_member1) { create(:crew_member, vessel: vessel, role: role) }
  let!(:crew_member2) { create(:crew_member, vessel: vessel, role: role) }

  describe '.call' do
    it 'creates certificate requests for all crew members' do
      expect {
        described_class.call(vessel: vessel)
      }.to change(CertificateRequest, :count).by(2)
    end

    it 'returns correct sent count' do
      result = described_class.call(vessel: vessel)
      expect(result.data[:sent]).to eq(2)
    end

    it 'sends emails to crew members' do
      expect {
        described_class.call(vessel: vessel)
      }.to have_enqueued_mail(CertificateRequestMailer, :request_certificates).twice
    end

    context 'when vessel has no crew members' do
      let(:empty_vessel) { create(:vessel) }

      it 'returns failure' do
        result = described_class.call(vessel: empty_vessel)
        expect(result).to be_failure
      end
    end

    context 'with specific crew member ids' do
      it 'only sends to specified crew members' do
        result = described_class.call(vessel: vessel, crew_member_ids: [ crew_member1.id ])
        expect(result.data[:sent]).to eq(1)
      end
    end
  end
end
