# frozen_string_literal: true

require "rails_helper"

RSpec.describe CertificateExtractionJob, type: :job do
  let(:crew_member) { create(:crew_member) }
  let(:certificate_type) { create(:certificate_type) }
  let(:certificate) { create(:certificate, crew_member: crew_member, certificate_type: certificate_type, status: "pending") }

  describe "#perform" do
    it "is enqueued in the default queue" do
      expect(described_class.new.queue_name).to eq("default")
    end

    context "when certificate does not exist" do
      it "does not raise an error" do
        expect { described_class.new.perform(0) }.not_to raise_error
      end

      it "returns early without processing" do
        expect_any_instance_of(described_class).not_to receive(:extract_certificate_data)
        described_class.new.perform(999_999)
      end
    end

    context "when certificate has no document attached" do
      it "returns early without processing" do
        expect(certificate.document).not_to be_attached
        expect { described_class.new.perform(certificate.id) }.not_to raise_error
        certificate.reload
        expect(certificate.status).to eq("pending") # unchanged
      end
    end

    context "when certificate has document attached" do
      before do
        certificate.document.attach(
          io: StringIO.new("fake pdf content"),
          filename: "certificate.pdf",
          content_type: "application/pdf"
        )
      end

      it "marks certificate as processing during extraction" do
        allow_any_instance_of(described_class).to receive(:extract_certificate_data) do
          expect(certificate.reload.status).to eq("processing")
          { success: true, extraction_method: "mock" }
        end

        described_class.new.perform(certificate.id)
      end

      context "with successful extraction (mock)" do
        it "updates certificate with extracted data" do
          described_class.new.perform(certificate.id)
          certificate.reload

          expect(certificate.status).to eq("pending") # back to pending for review
          expect(certificate.extracted_data).to be_present
          expect(certificate.extracted_data["extraction_method"]).to eq("mock")
          expect(certificate.extracted_data["success"]).to be true
        end

        it "sets certificate_number from extraction" do
          described_class.new.perform(certificate.id)
          certificate.reload

          expect(certificate.certificate_number).to be_present
          expect(certificate.certificate_number).to start_with("MOCK-")
        end

        it "sets issue_date from extraction" do
          described_class.new.perform(certificate.id)
          certificate.reload

          expect(certificate.issue_date).to be_present
          expect(certificate.issue_date).to be < Date.current
        end

        it "sets expiry_date from extraction" do
          described_class.new.perform(certificate.id)
          certificate.reload

          expect(certificate.expiry_date).to be_present
          expect(certificate.expiry_date).to be > Date.current
        end
      end

      context "with failed extraction" do
        before do
          allow_any_instance_of(described_class).to receive(:extract_certificate_data).and_return({
            success: false,
            error: "Could not read document",
            extraction_method: "mock"
          })
        end

        it "sets status back to pending" do
          described_class.new.perform(certificate.id)
          certificate.reload

          expect(certificate.status).to eq("pending")
        end

        it "stores error in extracted_data" do
          described_class.new.perform(certificate.id)
          certificate.reload

          expect(certificate.extracted_data["error"]).to eq("Could not read document")
          expect(certificate.extracted_data["extraction_method"]).to be_present
        end
      end

      context "when extraction raises an error" do
        before do
          allow_any_instance_of(described_class).to receive(:extract_certificate_data)
            .and_raise(StandardError, "API connection failed")
        end

        it "sets status back to pending" do
          expect { described_class.new.perform(certificate.id) }.to raise_error(StandardError)
          certificate.reload

          expect(certificate.status).to eq("pending")
        end

        it "stores error message in extracted_data" do
          expect { described_class.new.perform(certificate.id) }.to raise_error(StandardError)
          certificate.reload

          expect(certificate.extracted_data["error"]).to eq("API connection failed")
          expect(certificate.extracted_data["extraction_method"]).to eq("error")
        end

        it "re-raises the error for job retry" do
          expect {
            described_class.new.perform(certificate.id)
          }.to raise_error(StandardError, "API connection failed")
        end
      end
    end
  end

  describe ".perform_later" do
    it "enqueues a job" do
      expect {
        described_class.perform_later(certificate.id)
      }.to have_enqueued_job(described_class).with(certificate.id)
    end
  end

  describe "re-enqueue prevention" do
    before do
      certificate.document.attach(
        io: StringIO.new("fake pdf content"),
        filename: "certificate.pdf",
        content_type: "application/pdf"
      )
    end

    it "sets extraction_method to prevent callback loop on success" do
      described_class.new.perform(certificate.id)
      certificate.reload

      expect(certificate.extracted_data["extraction_method"]).to be_present
    end

    it "sets extraction_method to prevent callback loop on failure" do
      allow_any_instance_of(described_class).to receive(:extract_certificate_data).and_return({
        success: false,
        error: "Failed"
      })

      described_class.new.perform(certificate.id)
      certificate.reload

      expect(certificate.extracted_data["extraction_method"]).to be_present
    end

    it "sets extraction_method to prevent callback loop on exception" do
      allow_any_instance_of(described_class).to receive(:extract_certificate_data)
        .and_raise(StandardError, "Boom")

      expect { described_class.new.perform(certificate.id) }.to raise_error(StandardError)
      certificate.reload

      expect(certificate.extracted_data["extraction_method"]).to eq("error")
    end
  end
end
