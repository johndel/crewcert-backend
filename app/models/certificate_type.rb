class CertificateType < ApplicationRecord
  has_many :certificates, dependent: :restrict_with_error
  has_many :matrix_requirements, dependent: :destroy

  validates :code, presence: true, uniqueness: true
  validates :name, presence: true

  scope :ordered, -> { order(:code) }

  def display_name
    "#{code} - #{name}"
  end
end
