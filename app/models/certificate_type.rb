class CertificateType < ApplicationRecord
  has_many :certificates, dependent: :restrict_with_error
  has_many :matrix_requirements, dependent: :destroy
  has_many :roles, -> { distinct }, through: :matrix_requirements
  has_many :vessels, -> { distinct }, through: :matrix_requirements

  validates :code, presence: true,
                   uniqueness: { case_sensitive: false },
                   length: { maximum: 50 },
                   format: { with: /\A[A-Z0-9\-_]+\z/i, message: "only allows letters, numbers, hyphens and underscores" }
  validates :name, presence: true, length: { maximum: 255 }
  validates :validity_period_months, numericality: { only_integer: true, greater_than: 0 }, allow_nil: true

  scope :ordered, -> { order(:code) }
  scope :with_validity, -> { where.not(validity_period_months: nil) }
  scope :no_expiry, -> { where(validity_period_months: nil) }
  scope :search, ->(query) {
    where("code ILIKE :q OR name ILIKE :q", q: "%#{sanitize_sql_like(query)}%")
  }

  def display_name
    "#{code} - #{name}"
  end

  # Check if this certificate type expires
  def expires?
    validity_period_months.present?
  end

  # Check if this certificate type can be deleted
  def deletable?
    certificates.empty? && matrix_requirements.empty?
  end

  # Calculate expected expiry date from issue date
  def expected_expiry_date(from_date = Date.current)
    return nil unless expires?
    from_date + validity_period_months.months
  end

  # Group by category based on code prefix
  def category
    case code
    when /^STCW/ then "STCW Certificates"
    when /^COC/ then "Certificates of Competency"
    when /^FLAG/ then "Flag State Certificates"
    when /^MED/ then "Medical Certificates"
    else "Other Certificates"
    end
  end
end
