# frozen_string_literal: true

require "rails_helper"

RSpec.describe CertificateExtractionJob, type: :job do
  describe "#perform" do
    it "is enqueued in the default queue" do
      expect(described_class.new.queue_name).to eq("default")
    end

    context "when certificate does not exist" do
      it "does not raise an error" do
        expect { described_class.new.perform(0) }.not_to raise_error
      end
    end
  end

  describe ".perform_later" do
    let(:crew_member) { create(:crew_member) }
    let(:certificate_type) { create(:certificate_type) }
    let(:certificate) { create(:certificate, crew_member: crew_member, certificate_type: certificate_type) }

    it "enqueues a job" do
      expect {
        described_class.perform_later(certificate.id)
      }.to have_enqueued_job(described_class).with(certificate.id)
    end
  end
end
