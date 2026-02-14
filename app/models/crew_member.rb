class CrewMember < ApplicationRecord
  belongs_to :vessel
  belongs_to :role
  has_many :certificates, dependent: :destroy
  has_many :certificate_requests, dependent: :destroy
  has_many :certificate_types, through: :certificates

  validates :first_name, presence: true, length: { maximum: 100 }
  validates :last_name, presence: true, length: { maximum: 100 }
  validates :email, presence: true,
                    format: { with: URI::MailTo::EMAIL_REGEXP },
                    uniqueness: { case_sensitive: false }
  validates :phone, length: { maximum: 50 }, allow_blank: true

  scope :ordered, -> { order(:last_name, :first_name) }
  scope :with_associations, -> { includes(:vessel, :role, certificates: :certificate_type) }

  def full_name
    "#{first_name} #{last_name}".strip
  end

  # Returns certificate type IDs required for this crew member
  def required_certificate_type_ids
    @required_certificate_type_ids ||= MatrixRequirement
      .where(vessel_id: vessel_id, role_id: role_id)
      .pluck(:certificate_type_id)
  end

  # Returns certificate types required for this crew member (single query)
  def required_certificate_types
    CertificateType.where(id: required_certificate_type_ids).ordered
  end

  # Returns mandatory certificate type IDs
  def mandatory_certificate_type_ids
    @mandatory_certificate_type_ids ||= MatrixRequirement
      .mandatory
      .where(vessel_id: vessel_id, role_id: role_id)
      .pluck(:certificate_type_id)
  end

  def mandatory_certificate_types
    CertificateType.where(id: mandatory_certificate_type_ids).ordered
  end

  # Returns verified certificate type IDs owned by this crew member
  def verified_certificate_type_ids
    @verified_certificate_type_ids ||= certificates.verified.pluck(:certificate_type_id)
  end

  # Returns missing certificate types (single query)
  def missing_certificates
    missing_ids = required_certificate_type_ids - verified_certificate_type_ids
    CertificateType.where(id: missing_ids).ordered
  end

  # Returns missing mandatory certificates
  def missing_mandatory_certificates
    missing_ids = mandatory_certificate_type_ids - verified_certificate_type_ids
    CertificateType.where(id: missing_ids).ordered
  end

  # Efficient compliance calculation
  def certificate_compliance_percentage
    required_count = required_certificate_type_ids.size
    return 100.0 if required_count.zero?

    verified_count = (required_certificate_type_ids & verified_certificate_type_ids).size
    (verified_count.to_f / required_count * 100).round(1)
  end

  # Compliance status for quick checks
  def compliant?
    missing_mandatory_certificates.empty?
  end

  # Clear memoized values when certificates change
  def clear_certificate_cache!
    @required_certificate_type_ids = nil
    @mandatory_certificate_type_ids = nil
    @verified_certificate_type_ids = nil
  end
end
