require 'rails_helper'

RSpec.describe CrewMember, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:first_name) }
    it { should validate_presence_of(:last_name) }
    it { should validate_presence_of(:email) }

    it 'validates email format' do
      crew_member = build(:crew_member, email: 'invalid-email')
      expect(crew_member).not_to be_valid
    end

    it 'validates email uniqueness' do
      create(:crew_member, email: 'test@example.com')
      crew_member = build(:crew_member, email: 'TEST@EXAMPLE.COM')
      expect(crew_member).not_to be_valid
    end
  end

  describe 'associations' do
    it { should belong_to(:vessel) }
    it { should belong_to(:role) }
    it { should have_many(:certificates).dependent(:destroy) }
    it { should have_many(:certificate_requests).dependent(:destroy) }
  end

  describe '#full_name' do
    it 'returns first and last name combined' do
      crew_member = build(:crew_member, first_name: 'John', last_name: 'Doe')
      expect(crew_member.full_name).to eq('John Doe')
    end
  end

  describe '#certificate_compliance_percentage' do
    let(:crew_member) { create(:crew_member) }

    it 'returns 100.0 when no certificates are required' do
      expect(crew_member.certificate_compliance_percentage).to eq(100.0)
    end
  end

  describe '#compliant?' do
    let(:crew_member) { create(:crew_member) }

    it 'returns true when no mandatory certificates are missing' do
      expect(crew_member.compliant?).to be true
    end
  end

  describe 'scopes' do
    it '.ordered orders by last_name and first_name' do
      b = create(:crew_member, first_name: 'Alice', last_name: 'Zulu')
      a = create(:crew_member, first_name: 'Bob', last_name: 'Alpha')
      expect(CrewMember.ordered).to eq([a, b])
    end
  end
end
