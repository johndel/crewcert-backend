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
end
