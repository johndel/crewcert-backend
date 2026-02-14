# frozen_string_literal: true

module Compliance
  class VesselReportService < ApplicationService
    def initialize(vessel:)
      @vessel = vessel
    end

    def call
      crew_members = vessel.crew_members.includes(:role, certificates: :certificate_type)
      return success(empty_report) if crew_members.empty?

      report = build_report(crew_members)
      success(report)
    end

    private

    attr_reader :vessel

    def empty_report
      {
        vessel: vessel,
        total_crew: 0,
        compliance_percentage: 100.0,
        compliant_crew: 0,
        non_compliant_crew: 0,
        certificates: {
          total_required: 0,
          verified: 0,
          pending: 0,
          missing: 0,
          expired: 0,
          expiring_soon: 0
        },
        crew_details: [],
        alerts: []
      }
    end

    def build_report(crew_members)
      details = crew_members.map { |cm| crew_member_details(cm) }

      certificates = aggregate_certificate_stats(details)
      alerts = generate_alerts(details)

      compliant_count = details.count { |d| d[:compliant] }

      {
        vessel: vessel,
        total_crew: details.size,
        compliance_percentage: calculate_percentage(compliant_count, details.size),
        compliant_crew: compliant_count,
        non_compliant_crew: details.size - compliant_count,
        certificates: certificates,
        crew_details: details,
        alerts: alerts
      }
    end

    def crew_member_details(crew_member)
      required_ids = crew_member.mandatory_certificate_type_ids
      verified_ids = crew_member.verified_certificate_type_ids
      missing_ids = required_ids - verified_ids

      certs = crew_member.certificates.verified
      expired = certs.select(&:expired?)
      expiring = certs.select(&:expiring_soon?)

      {
        crew_member: crew_member,
        role: crew_member.role,
        compliant: missing_ids.empty? && expired.empty?,
        required_count: required_ids.size,
        verified_count: (required_ids & verified_ids).size,
        missing_count: missing_ids.size,
        expired_count: expired.size,
        expiring_count: expiring.size,
        expired_certificates: expired,
        expiring_certificates: expiring,
        missing_certificate_type_ids: missing_ids
      }
    end

    def aggregate_certificate_stats(details)
      {
        total_required: details.sum { |d| d[:required_count] },
        verified: details.sum { |d| d[:verified_count] },
        pending: Certificate.joins(:crew_member)
                            .where(crew_members: { vessel_id: vessel.id })
                            .pending_review.count,
        missing: details.sum { |d| d[:missing_count] },
        expired: details.sum { |d| d[:expired_count] },
        expiring_soon: details.sum { |d| d[:expiring_count] }
      }
    end

    def generate_alerts(details)
      alerts = []

      # Expired certificates
      expired_crew = details.select { |d| d[:expired_count] > 0 }
      if expired_crew.any?
        alerts << {
          type: :danger,
          title: "Expired Certificates",
          message: "#{expired_crew.size} crew member(s) have expired certificates",
          crew_members: expired_crew.map { |d| d[:crew_member] }
        }
      end

      # Expiring soon
      expiring_crew = details.select { |d| d[:expiring_count] > 0 }
      if expiring_crew.any?
        alerts << {
          type: :warning,
          title: "Certificates Expiring Soon",
          message: "#{expiring_crew.size} crew member(s) have certificates expiring within 30 days",
          crew_members: expiring_crew.map { |d| d[:crew_member] }
        }
      end

      # Missing certificates
      missing_crew = details.select { |d| d[:missing_count] > 0 }
      if missing_crew.any?
        alerts << {
          type: :danger,
          title: "Missing Certificates",
          message: "#{missing_crew.size} crew member(s) are missing required certificates",
          crew_members: missing_crew.map { |d| d[:crew_member] }
        }
      end

      alerts
    end

    def calculate_percentage(numerator, denominator)
      return 100.0 if denominator.zero?
      (numerator.to_f / denominator * 100).round(1)
    end
  end
end
