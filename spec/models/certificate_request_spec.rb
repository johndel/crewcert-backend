require 'rails_helper'

RSpec.describe CertificateRequest, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:status) }
    it { should validate_inclusion_of(:status).in_array(CertificateRequest::STATUSES) }

    context 'token uniqueness' do
      subject { create(:certificate_request) }
      it { should validate_uniqueness_of(:token) }
    end
  end

  describe 'associations' do
    it { should belong_to(:crew_member) }
  end

  describe 'callbacks' do
    it 'generates token on creation' do
      request = create(:certificate_request)
      expect(request.token).to be_present
      expect(request.token.length).to be >= 32
    end

    it 'sets expiry date on creation' do
      request = create(:certificate_request)
      expect(request.expires_at).to be_present
      expect(request.expires_at).to be > Time.current
    end
  end

  describe '#expired?' do
    it 'returns true when expires_at is in the past' do
      request = build(:certificate_request, expires_at: 1.day.ago)
      expect(request.expired?).to be true
    end

    it 'returns false when expires_at is in the future' do
      request = build(:certificate_request, expires_at: 1.day.from_now)
      expect(request.expired?).to be false
    end
  end
end
