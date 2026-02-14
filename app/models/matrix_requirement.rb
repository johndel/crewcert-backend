class MatrixRequirement < ApplicationRecord
  REQUIREMENT_LEVELS = %w[M O].freeze

  belongs_to :vessel
  belongs_to :role
  belongs_to :certificate_type

  validates :requirement_level, presence: true, inclusion: { in: REQUIREMENT_LEVELS }
  validates :certificate_type_id, uniqueness: { scope: [ :vessel_id, :role_id ] }

  scope :mandatory, -> { where(requirement_level: "M") }
  scope :optional, -> { where(requirement_level: "O") }

  def mandatory?
    requirement_level == "M"
  end

  def optional?
    requirement_level == "O"
  end
end
