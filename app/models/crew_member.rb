class CrewMember < ApplicationRecord
  belongs_to :vessel
  belongs_to :role
  has_many :certificates, dependent: :destroy
  has_many :certificate_requests, dependent: :destroy

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, format: { with: /\A[^@\s]+@[^@\s]+\z/ }

  scope :ordered, -> { order(:last_name, :first_name) }

  def full_name
    "#{first_name} #{last_name}".strip
  end

  def required_certificate_types
    vessel.matrix_requirements.where(role: role).includes(:certificate_type).map(&:certificate_type)
  end

  def mandatory_certificate_types
    vessel.matrix_requirements.mandatory.where(role: role).includes(:certificate_type).map(&:certificate_type)
  end

  def missing_certificates
    required_ids = required_certificate_types.pluck(:id)
    owned_ids = certificates.verified.pluck(:certificate_type_id)
    CertificateType.where(id: required_ids - owned_ids)
  end

  def certificate_compliance_percentage
    required = required_certificate_types.count
    return 100.0 if required.zero?

    owned = certificates.verified.where(certificate_type: required_certificate_types).count
    (owned.to_f / required * 100).round(1)
  end
end
