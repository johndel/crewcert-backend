class Certificate < ApplicationRecord
  STATUSES = %w[pending processing verified rejected].freeze

  # Ransack configuration
  def self.ransackable_attributes(auth_object = nil)
    %w[status certificate_number issue_date expiry_date verified_at created_at updated_at crew_member_id certificate_type_id]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[crew_member certificate_type verified_by]
  end
  ALLOWED_DOCUMENT_TYPES = %w[application/pdf image/jpeg image/png image/webp].freeze
  MAX_DOCUMENT_SIZE = 10.megabytes

  belongs_to :crew_member
  belongs_to :certificate_type
  belongs_to :verified_by, class_name: 'User', optional: true
  has_one_attached :document

  validates :status, presence: true, inclusion: { in: STATUSES }
  validates :certificate_number, length: { maximum: 100 }, allow_blank: true
  validates :issue_date, comparison: { less_than_or_equal_to: -> { Date.current } }, allow_blank: true
  validates :expiry_date, comparison: { greater_than: :issue_date }, if: -> { issue_date.present? && expiry_date.present? }
  validate :document_type_and_size

  # Trigger AI extraction when document is attached
  after_commit :enqueue_extraction, if: :should_extract?
  after_save :clear_crew_member_cache

  scope :pending, -> { where(status: 'pending') }
  scope :processing, -> { where(status: 'processing') }
  scope :verified, -> { where(status: 'verified') }
  scope :rejected, -> { where(status: 'rejected') }
  scope :pending_review, -> { where(status: %w[pending processing]) }
  scope :expiring_soon, -> { verified.where(expiry_date: Date.current..30.days.from_now) }
  scope :expired, -> { verified.where('expiry_date < ?', Date.current) }
  scope :valid_now, -> { verified.where('expiry_date IS NULL OR expiry_date >= ?', Date.current) }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_crew_member, ->(crew_member) { where(crew_member: crew_member) }
  scope :by_certificate_type, ->(certificate_type) { where(certificate_type: certificate_type) }
  scope :with_associations, -> { includes(:crew_member, :certificate_type, :verified_by) }

  def verify!(user)
    transaction do
      update!(
        status: 'verified',
        verified_at: Time.current,
        verified_by: user
      )
    end
  end

  def reject!(user, reason: nil)
    transaction do
      update!(
        status: 'rejected',
        verified_at: Time.current,
        verified_by: user,
        rejection_reason: reason
      )
    end
  end

  def expired?
    expiry_date.present? && expiry_date < Date.current
  end

  def expiring_soon?(days: 30)
    expiry_date.present? && expiry_date.between?(Date.current, days.days.from_now)
  end

  def days_until_expiry
    return nil unless expiry_date.present?
    (expiry_date - Date.current).to_i
  end

  def valid_certificate?
    status == 'verified' && !expired?
  end

  def can_verify?
    status.in?(%w[pending processing])
  end

  def can_reject?
    status.in?(%w[pending processing])
  end

  # Status badge class for views
  def status_badge_class
    case status
    when 'pending' then 'bg-warning'
    when 'processing' then 'bg-info'
    when 'verified' then expired? ? 'bg-secondary' : 'bg-success'
    when 'rejected' then 'bg-danger'
    else 'bg-secondary'
    end
  end

  private

  def document_type_and_size
    return unless document.attached?

    unless document.content_type.in?(ALLOWED_DOCUMENT_TYPES)
      errors.add(:document, "must be a PDF, JPEG, PNG, or WebP file")
    end

    if document.byte_size > MAX_DOCUMENT_SIZE
      errors.add(:document, "must be less than #{MAX_DOCUMENT_SIZE / 1.megabyte}MB")
    end
  end

  def should_extract?
    return false if Rails.env.test?
    document.attached? && status == 'pending' && !extracted_data&.dig('extraction_method')
  end

  def enqueue_extraction
    CertificateExtractionJob.perform_later(id)
  end

  def clear_crew_member_cache
    crew_member&.clear_certificate_cache!
  end
end
