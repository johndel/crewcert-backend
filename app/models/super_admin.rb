class SuperAdmin < ApplicationRecord
  devise :database_authenticatable, :trackable, :rememberable

  generates_token_for :magic_link, expires_in: 1.hour do
    current_sign_in_at&.to_i
  end

  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: /\A[^@\s]+@[^@\s]+\z/ }

  before_validation :ensure_password

  def ensure_password!
    return if encrypted_password.present?

    ensure_password
    save!
  end

  private

  def ensure_password
    return if encrypted_password.present? || password.present?

    temp_password = Devise.friendly_token
    self.password = temp_password
    self.password_confirmation = temp_password
  end
end
