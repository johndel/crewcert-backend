class CertificateRequest < ApplicationRecord
  STATUSES = %w[pending sent submitted expired].freeze
  TOKEN_EXPIRY = 7.days

  belongs_to :crew_member

  validates :token, presence: true, uniqueness: true
  validates :status, presence: true, inclusion: { in: STATUSES }

  before_validation :generate_token, on: :create
  before_validation :set_expiry, on: :create

  scope :pending, -> { where(status: "pending") }
  scope :sent, -> { where(status: "sent") }
  scope :submitted, -> { where(status: "submitted") }
  scope :active, -> { where("expires_at > ?", Time.current).where(status: %w[pending sent]) }

  def send_request!
    update!(status: "sent", sent_at: Time.current)
    CertificateRequestMailer.request_certificates(self).deliver_later
  end

  def submit!
    update!(status: "submitted", submitted_at: Time.current)
  end

  def expired?
    expires_at.present? && expires_at < Time.current
  end

  def upload_url
    Rails.application.routes.url_helpers.upload_url(token: token)
  end

  private

  def generate_token
    self.token ||= SecureRandom.urlsafe_base64(32)
  end

  def set_expiry
    self.expires_at ||= TOKEN_EXPIRY.from_now
  end
end
