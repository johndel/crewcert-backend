class Certificate < ApplicationRecord
  STATUSES = %w[pending processing verified rejected].freeze

  belongs_to :crew_member
  belongs_to :certificate_type
  belongs_to :verified_by, class_name: 'User', optional: true
  has_one_attached :document

  validates :status, presence: true, inclusion: { in: STATUSES }

  scope :pending, -> { where(status: 'pending') }
  scope :processing, -> { where(status: 'processing') }
  scope :verified, -> { where(status: 'verified') }
  scope :rejected, -> { where(status: 'rejected') }
  scope :pending_review, -> { where(status: %w[pending processing]) }
  scope :expiring_soon, -> { verified.where(expiry_date: Date.today..30.days.from_now) }
  scope :expired, -> { verified.where('expiry_date < ?', Date.today) }

  def verify!(user)
    update!(
      status: 'verified',
      verified_at: Time.current,
      verified_by: user
    )
  end

  def reject!(user)
    update!(
      status: 'rejected',
      verified_at: Time.current,
      verified_by: user
    )
  end

  def expired?
    expiry_date.present? && expiry_date < Date.today
  end

  def expiring_soon?
    expiry_date.present? && expiry_date.between?(Date.today, 30.days.from_now)
  end

  def valid_certificate?
    status == 'verified' && !expired?
  end
end
