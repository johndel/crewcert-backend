class Vessel < ApplicationRecord
  IMO_FORMAT = /\A\d{7}\z/

  # Ransack configuration
  def self.ransackable_attributes(auth_object = nil)
    %w[name imo management_company created_at updated_at]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[crew_members]
  end

  has_many :crew_members, dependent: :destroy
  has_many :matrix_requirements, dependent: :destroy
  has_many :certificate_types, through: :matrix_requirements
  has_many :roles, -> { distinct }, through: :crew_members

  validates :name, presence: true, length: { maximum: 255 }
  validates :imo, uniqueness: true,
                  format: { with: IMO_FORMAT, message: "must be 7 digits" },
                  allow_blank: true
  validates :management_company, length: { maximum: 255 }, allow_blank: true

  scope :ordered, -> { order(:name) }
  scope :with_crew_count, -> {
    left_joins(:crew_members)
      .select("vessels.*, COUNT(crew_members.id) as crew_count")
      .group("vessels.id")
  }

  # Calculate overall compliance percentage for the vessel
  def compliance_percentage
    return 100.0 if crew_members.empty?

    total_required = 0
    total_compliant = 0

    crew_members.includes(certificates: :certificate_type).find_each do |cm|
      required = cm.mandatory_certificate_type_ids.size
      compliant = (cm.mandatory_certificate_type_ids & cm.verified_certificate_type_ids).size
      total_required += required
      total_compliant += compliant
    end

    return 100.0 if total_required.zero?
    (total_compliant.to_f / total_required * 100).round(1)
  end

  # Quick stats for dashboard
  def compliance_stats
    stats = { total_crew: 0, compliant_crew: 0, expiring_soon: 0, expired: 0 }

    crew_members.includes(:certificates).find_each do |cm|
      stats[:total_crew] += 1
      stats[:compliant_crew] += 1 if cm.compliant?
      stats[:expiring_soon] += cm.certificates.verified.expiring_soon.count
      stats[:expired] += cm.certificates.verified.expired.count
    end

    stats
  end
end
