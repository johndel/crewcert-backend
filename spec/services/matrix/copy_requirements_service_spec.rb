# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Matrix::CopyRequirementsService do
  let(:source_vessel) { create(:vessel) }
  let(:target_vessel) { create(:vessel) }
  let(:role1) { create(:role) }
  let(:role2) { create(:role) }
  let(:cert_type1) { create(:certificate_type) }
  let(:cert_type2) { create(:certificate_type) }

  before do
    create(:matrix_requirement, vessel: source_vessel, role: role1, certificate_type: cert_type1, requirement_level: 'M')
    create(:matrix_requirement, vessel: source_vessel, role: role1, certificate_type: cert_type2, requirement_level: 'O')
    create(:matrix_requirement, vessel: source_vessel, role: role2, certificate_type: cert_type1, requirement_level: 'M')
  end

  describe '.call' do
    it 'returns success' do
      result = described_class.call(source_vessel: source_vessel, target_vessel: target_vessel)
      expect(result).to be_success
    end

    it 'copies all requirements to target vessel' do
      expect {
        described_class.call(source_vessel: source_vessel, target_vessel: target_vessel)
      }.to change { target_vessel.matrix_requirements.count }.by(3)
    end

    it 'preserves requirement level' do
      described_class.call(source_vessel: source_vessel, target_vessel: target_vessel)
      mandatory_count = target_vessel.matrix_requirements.mandatory.count
      expect(mandatory_count).to eq(2)
    end

    it 'returns copied count in data' do
      result = described_class.call(source_vessel: source_vessel, target_vessel: target_vessel)
      expect(result.data[:copied]).to eq(3)
    end

    context 'when target has existing requirements' do
      before do
        create(:matrix_requirement, vessel: target_vessel, role: role1, certificate_type: cert_type1)
      end

      it 'skips existing requirements' do
        expect {
          described_class.call(source_vessel: source_vessel, target_vessel: target_vessel)
        }.to change { target_vessel.matrix_requirements.count }.by(2)
      end
    end

    context 'when source has no requirements' do
      let(:empty_vessel) { create(:vessel) }

      it 'returns failure' do
        result = described_class.call(source_vessel: empty_vessel, target_vessel: target_vessel)
        expect(result).to be_failure
      end
    end

    context 'when copying to same vessel' do
      it 'returns failure' do
        result = described_class.call(source_vessel: source_vessel, target_vessel: source_vessel)
        expect(result).to be_failure
      end

      it 'includes error message' do
        result = described_class.call(source_vessel: source_vessel, target_vessel: source_vessel)
        expect(result.error).to include('same')
      end
    end

    context 'with overwrite option' do
      before do
        create(:matrix_requirement, vessel: target_vessel, role: role1, certificate_type: cert_type1, requirement_level: 'O')
      end

      it 'removes existing requirements when overwrite is true' do
        described_class.call(source_vessel: source_vessel, target_vessel: target_vessel, overwrite: true)
        expect(target_vessel.matrix_requirements.count).to eq(3)
      end
    end
  end
end
