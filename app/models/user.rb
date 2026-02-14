class User < ApplicationRecord
  devise :database_authenticatable, :trackable, :rememberable

  generates_token_for :magic_link, expires_in: 1.hour do
    current_sign_in_at&.to_i
  end

  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: /\A[^@\s]+@[^@\s]+\z/ }
  validates :first_name, :last_name, presence: true

  before_validation :ensure_password

  def full_name
    "#{first_name} #{last_name}".strip
  end

  private

  def ensure_password
    self.password = generate_random_password if encrypted_password.blank?
  end

  def generate_random_password
    SecureRandom.hex(32)
  end
end
