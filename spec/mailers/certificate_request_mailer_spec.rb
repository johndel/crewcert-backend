# frozen_string_literal: true

require "rails_helper"

RSpec.describe CertificateRequestMailer, type: :mailer do
  let(:vessel) { create(:vessel) }
  let(:role) { create(:role) }
  let(:crew_member) { create(:crew_member, vessel: vessel, role: role, email: "sailor@example.com") }
  let(:certificate_request) { create(:certificate_request, crew_member: crew_member) }

  describe "#request_certificates" do
    let(:mail) { described_class.request_certificates(certificate_request) }

    it "sends to the crew member's email" do
      expect(mail.to).to eq([ "sailor@example.com" ])
    end

    it "includes the vessel name in the subject" do
      expect(mail.subject).to include(vessel.name)
    end

    it "includes the upload URL in the body" do
      expect(mail.body.encoded).to include(certificate_request.token)
    end

    it "includes the crew member's name in the body" do
      expect(mail.body.encoded).to include(crew_member.first_name)
    end

    it "includes the vessel name in the body" do
      expect(mail.body.encoded).to include(vessel.name)
    end

    it "includes the role name in the body" do
      expect(mail.body.encoded).to include(role.name)
    end
  end
end
