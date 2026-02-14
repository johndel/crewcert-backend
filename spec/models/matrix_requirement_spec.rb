require 'rails_helper'

RSpec.describe MatrixRequirement, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:requirement_level) }
    it { should validate_inclusion_of(:requirement_level).in_array(MatrixRequirement::REQUIREMENT_LEVELS) }

    context 'uniqueness' do
      subject { create(:matrix_requirement) }
      it { should validate_uniqueness_of(:certificate_type_id).scoped_to([ :vessel_id, :role_id ]) }
    end
  end

  describe 'associations' do
    it { should belong_to(:vessel) }
    it { should belong_to(:role) }
    it { should belong_to(:certificate_type) }
  end

  describe '#mandatory?' do
    it 'returns true for M level' do
      requirement = build(:matrix_requirement, requirement_level: 'M')
      expect(requirement.mandatory?).to be true
    end

    it 'returns false for O level' do
      requirement = build(:matrix_requirement, requirement_level: 'O')
      expect(requirement.mandatory?).to be false
    end
  end

  describe '#optional?' do
    it 'returns true for O level' do
      requirement = build(:matrix_requirement, requirement_level: 'O')
      expect(requirement.optional?).to be true
    end
  end
end
