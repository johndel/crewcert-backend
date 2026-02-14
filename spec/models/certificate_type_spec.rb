require 'rails_helper'

RSpec.describe CertificateType, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:code) }
    it { should validate_presence_of(:name) }

    context 'code uniqueness' do
      subject { create(:certificate_type) }
      it { should validate_uniqueness_of(:code) }
    end
  end

  describe 'associations' do
    it { should have_many(:certificates).dependent(:restrict_with_error) }
    it { should have_many(:matrix_requirements).dependent(:destroy) }
  end

  describe '#display_name' do
    it 'returns code and name combined' do
      cert_type = build(:certificate_type, code: 'STCW', name: 'Basic Safety Training')
      expect(cert_type.display_name).to eq('STCW - Basic Safety Training')
    end
  end
end
