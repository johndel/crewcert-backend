require 'rails_helper'

RSpec.describe Vessel, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }

    it 'validates IMO format' do
      vessel = build(:vessel, imo: 'invalid')
      expect(vessel).not_to be_valid
      expect(vessel.errors[:imo]).to include("must be 7 digits")
    end

    it 'validates IMO uniqueness' do
      create(:vessel, imo: '1234567')
      vessel = build(:vessel, imo: '1234567')
      expect(vessel).not_to be_valid
      expect(vessel.errors[:imo]).to include("has already been taken")
    end

    it 'allows blank IMO' do
      vessel = build(:vessel, imo: nil)
      expect(vessel).to be_valid
    end
  end

  describe 'associations' do
    it { should have_many(:crew_members).dependent(:destroy) }
    it { should have_many(:matrix_requirements).dependent(:destroy) }
  end
end
