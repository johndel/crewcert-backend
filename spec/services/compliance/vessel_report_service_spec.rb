# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Compliance::VesselReportService do
  let(:vessel) { create(:vessel) }
  let(:role) { create(:role) }
  let(:cert_type1) { create(:certificate_type, code: 'STCW-01') }
  let(:cert_type2) { create(:certificate_type, code: 'STCW-02') }
  let!(:crew_member) { create(:crew_member, vessel: vessel, role: role) }

  before do
    create(:matrix_requirement, vessel: vessel, role: role, certificate_type: cert_type1, requirement_level: 'M')
    create(:matrix_requirement, vessel: vessel, role: role, certificate_type: cert_type2, requirement_level: 'O')
  end

  describe '.call' do
    it 'returns success' do
      result = described_class.call(vessel: vessel)
      expect(result).to be_success
    end

    it 'includes vessel in report' do
      result = described_class.call(vessel: vessel)
      expect(result.data[:vessel]).to eq(vessel)
    end

    it 'includes total crew' do
      result = described_class.call(vessel: vessel)
      expect(result.data[:total_crew]).to eq(1)
    end

    it 'includes compliance percentage' do
      result = described_class.call(vessel: vessel)
      expect(result.data[:compliance_percentage]).to be_a(Float)
    end

    it 'includes crew details' do
      result = described_class.call(vessel: vessel)
      expect(result.data[:crew_details]).to be_present
    end

    context 'with compliant crew member' do
      before do
        create(:certificate, :verified, crew_member: crew_member, certificate_type: cert_type1)
      end

      it 'shows crew member as compliant' do
        result = described_class.call(vessel: vessel)
        crew_data = result.data[:crew_details].first
        expect(crew_data[:compliant]).to be true
      end

      it 'shows 100% compliance' do
        result = described_class.call(vessel: vessel)
        expect(result.data[:compliance_percentage]).to eq(100.0)
      end
    end

    context 'with non-compliant crew member' do
      it 'shows crew member as non-compliant' do
        result = described_class.call(vessel: vessel)
        crew_data = result.data[:crew_details].first
        expect(crew_data[:compliant]).to be false
      end

      it 'shows missing count' do
        result = described_class.call(vessel: vessel)
        crew_data = result.data[:crew_details].first
        expect(crew_data[:missing_count]).to eq(1) # Only mandatory cert_type1 is required
      end
    end

    context 'with expiring certificates' do
      before do
        create(:certificate, :verified, :expiring_soon,
               crew_member: crew_member, certificate_type: cert_type1)
      end

      it 'includes expiring count in crew details' do
        result = described_class.call(vessel: vessel)
        crew_data = result.data[:crew_details].first
        expect(crew_data[:expiring_count]).to eq(1)
      end
    end

    context 'with expired certificates' do
      before do
        create(:certificate, :verified, :expired,
               crew_member: crew_member, certificate_type: cert_type1)
      end

      it 'includes expired count in crew details' do
        result = described_class.call(vessel: vessel)
        crew_data = result.data[:crew_details].first
        expect(crew_data[:expired_count]).to eq(1)
      end

      it 'marks crew member as non-compliant due to expired cert' do
        result = described_class.call(vessel: vessel)
        crew_data = result.data[:crew_details].first
        expect(crew_data[:compliant]).to be false
      end
    end

    context 'with empty vessel' do
      let(:empty_vessel) { create(:vessel) }

      it 'returns success' do
        result = described_class.call(vessel: empty_vessel)
        expect(result).to be_success
      end

      it 'shows 100% compliance for empty vessel' do
        result = described_class.call(vessel: empty_vessel)
        expect(result.data[:compliance_percentage]).to eq(100.0)
      end
    end
  end
end
