require 'rails_helper'

RSpec.describe Certificate, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:status) }
    it { should validate_inclusion_of(:status).in_array(Certificate::STATUSES) }
  end

  describe 'associations' do
    it { should belong_to(:crew_member) }
    it { should belong_to(:certificate_type) }
    it { should belong_to(:verified_by).class_name('User').optional }
  end

  describe 'scopes' do
    let!(:pending_cert) { create(:certificate, status: 'pending') }
    let!(:verified_cert) { create(:certificate, :verified) }

    it 'returns pending certificates' do
      expect(Certificate.pending).to include(pending_cert)
      expect(Certificate.pending).not_to include(verified_cert)
    end

    it 'returns verified certificates' do
      expect(Certificate.verified).to include(verified_cert)
      expect(Certificate.verified).not_to include(pending_cert)
    end
  end

  describe '#expired?' do
    it 'returns true when expiry date is in the past' do
      cert = build(:certificate, expiry_date: 1.day.ago)
      expect(cert.expired?).to be true
    end

    it 'returns false when expiry date is in the future' do
      cert = build(:certificate, expiry_date: 1.day.from_now)
      expect(cert.expired?).to be false
    end
  end

  describe '#verify!' do
    let(:certificate) { create(:certificate) }
    let(:user) { create(:user) }

    it 'updates status to verified' do
      certificate.verify!(user)
      expect(certificate.status).to eq('verified')
      expect(certificate.verified_by).to eq(user)
      expect(certificate.verified_at).to be_present
    end
  end
end
