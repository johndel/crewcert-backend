# frozen_string_literal: true

module Certificates
  class VerifyService < ApplicationService
    def initialize(certificate:, user:, notes: nil)
      @certificate = certificate
      @user = user
      @notes = notes
    end

    def call
      return failure("Certificate cannot be verified") unless certificate.can_verify?
      return failure("Document not attached") unless certificate.document.attached?

      ActiveRecord::Base.transaction do
        certificate.verify!(user)
        log_action(:verified)
        notify_crew_member if should_notify?
      end

      success(certificate)
    rescue ActiveRecord::RecordInvalid => e
      failure(e.message)
    rescue StandardError => e
      Rails.logger.error("Certificate verification failed: #{e.message}")
      failure("An error occurred during verification")
    end

    private

    attr_reader :certificate, :user, :notes

    def log_action(action)
      Rails.logger.info(
        "Certificate ##{certificate.id} #{action} by User ##{user.id} " \
        "(#{certificate.certificate_type.code} for #{certificate.crew_member.full_name})"
      )
    end

    def should_notify?
      certificate.crew_member.email.present?
    end

    def notify_crew_member
      # TODO: Implement notification mailer
      # CertificateMailer.verified(certificate).deliver_later
    end
  end
end
