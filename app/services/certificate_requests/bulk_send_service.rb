# frozen_string_literal: true

module CertificateRequests
  class BulkSendService < ApplicationService
    def initialize(vessel:, crew_member_ids: nil, sent_by: nil)
      @vessel = vessel
      @crew_member_ids = crew_member_ids
      @sent_by = sent_by
    end

    def call
      crew_members = fetch_crew_members
      return failure("No crew members found") if crew_members.empty?

      results = { sent: 0, failed: 0, errors: [] }

      crew_members.find_each do |crew_member|
        result = send_request(crew_member)
        if result.success?
          results[:sent] += 1
        else
          results[:failed] += 1
          results[:errors] << "#{crew_member.full_name}: #{result.error}"
        end
      end

      if results[:failed].zero?
        success(results)
      else
        failure("Some requests failed", results)
      end
    end

    private

    attr_reader :vessel, :crew_member_ids, :sent_by

    def fetch_crew_members
      scope = vessel.crew_members
      scope = scope.where(id: crew_member_ids) if crew_member_ids.present?
      scope
    end

    def send_request(crew_member)
      ActiveRecord::Base.transaction do
        request = crew_member.certificate_requests.create!(status: "pending")
        request.send_request!
        ServiceResult.new(success: true, data: request)
      end
    rescue StandardError => e
      Rails.logger.error("Failed to send certificate request to #{crew_member.id}: #{e.message}")
      ServiceResult.new(success: false, error: e.message)
    end
  end
end
