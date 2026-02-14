require 'rails_helper'

RSpec.describe Vessel, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:name) }

    context 'imo uniqueness' do
      subject { create(:vessel) }
      it { should validate_uniqueness_of(:imo) }
    end
  end

  describe 'associations' do
    it { should have_many(:crew_members).dependent(:destroy) }
    it { should have_many(:matrix_requirements).dependent(:destroy) }
  end
end
