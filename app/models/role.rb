class Role < ApplicationRecord
  has_many :crew_members, dependent: :restrict_with_error
  has_many :matrix_requirements, dependent: :destroy
  has_many :vessels, -> { distinct }, through: :crew_members

  validates :name, presence: true, uniqueness: { case_sensitive: false }, length: { maximum: 100 }
  validates :position, presence: true, numericality: { only_integer: true, greater_than: 0 }

  scope :ordered, -> { order(:position) }
  scope :with_crew_count, -> {
    left_joins(:crew_members)
      .select("roles.*, COUNT(crew_members.id) as crew_count")
      .group("roles.id")
  }

  before_validation :set_position, on: :create

  # Check if role has any dependencies
  def deletable?
    crew_members.empty? && matrix_requirements.empty?
  end

  # Get certificate types required for this role across all vessels
  def required_certificate_types
    CertificateType.where(
      id: matrix_requirements.select(:certificate_type_id)
    ).ordered
  end

  private

  def set_position
    return if position.present?

    # Use database-level locking to prevent race conditions
    self.position = self.class.connection.select_value(
      "SELECT COALESCE(MAX(position), 0) + 1 FROM roles"
    ).to_i
  end
end
