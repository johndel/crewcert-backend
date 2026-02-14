class Vessel < ApplicationRecord
  has_many :crew_members, dependent: :destroy
  has_many :matrix_requirements, dependent: :destroy
  has_many :certificate_types, through: :matrix_requirements

  validates :name, presence: true
  validates :imo, uniqueness: true, allow_blank: true

  scope :ordered, -> { order(:name) }
end
