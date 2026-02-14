require 'rails_helper'

RSpec.describe Role, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }

    context 'name uniqueness' do
      subject { create(:role) }
      it { should validate_uniqueness_of(:name) }
    end
  end

  describe 'associations' do
    it { should have_many(:crew_members).dependent(:restrict_with_error) }
    it { should have_many(:matrix_requirements).dependent(:destroy) }
  end

  describe 'callbacks' do
    it 'sets position automatically if not provided' do
      role = create(:role)
      expect(role.position).to be_present
    end

    it 'increments position for each new role' do
      role1 = create(:role)
      role2 = create(:role)
      expect(role2.position).to be > role1.position
    end
  end
end
