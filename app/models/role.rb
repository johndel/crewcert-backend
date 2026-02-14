class Role < ApplicationRecord
  has_many :crew_members, dependent: :restrict_with_error
  has_many :matrix_requirements, dependent: :destroy

  validates :name, presence: true, uniqueness: true
  validates :position, presence: true

  scope :ordered, -> { order(:position) }

  before_validation :set_position, on: :create

  private

  def set_position
    self.position ||= (Role.maximum(:position) || 0) + 1
  end
end
