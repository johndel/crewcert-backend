# frozen_string_literal: true

module Admin
  class HomeController < BaseController
    def index
      @stats = calculate_stats
      @recent_certificates = Certificate.with_associations.recent.limit(5)
      @expiring_certificates = Certificate.with_associations.expiring_soon.limit(5)
      @vessels_needing_attention = vessels_needing_attention
      @recent_activity = recent_activity
    end

    private

    def calculate_stats
      {
        vessels: Vessel.count,
        crew_members: CrewMember.count,
        pending_reviews: Certificate.pending_review.count,
        expiring_soon: Certificate.expiring_soon.count,
        expired: Certificate.expired.count,
        verified_today: Certificate.verified.where("verified_at >= ?", Date.current.beginning_of_day).count,
        certificate_types: CertificateType.count,
        roles: Role.count
      }
    end

    def vessels_needing_attention
      Vessel.includes(:crew_members).limit(5).select do |vessel|
        stats = vessel.compliance_stats
        stats[:total_crew] > 0 && stats[:compliant_crew] < stats[:total_crew]
      end
    end

    def recent_activity
      # Get recent certificate uploads and verifications
      Certificate
        .with_associations
        .where("created_at >= ? OR verified_at >= ?", 7.days.ago, 7.days.ago)
        .order(Arel.sql("GREATEST(COALESCE(verified_at, created_at), created_at) DESC"))
        .limit(10)
        .map do |cert|
          if cert.verified_at && cert.verified_at >= 7.days.ago
            { type: :verified, certificate: cert, timestamp: cert.verified_at }
          else
            { type: :uploaded, certificate: cert, timestamp: cert.created_at }
          end
        end
    end
  end
end
