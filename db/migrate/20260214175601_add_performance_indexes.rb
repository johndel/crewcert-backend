class AddPerformanceIndexes < ActiveRecord::Migration[8.1]
  def change
    # Email uniqueness index (case-insensitive)
    add_index :crew_members, "LOWER(email)", name: "index_crew_members_on_lower_email", unique: true, if_not_exists: true

    # Certificate status and expiry for dashboard queries
    add_index :certificates, [ :status, :expiry_date ], name: "index_certificates_on_status_and_expiry", if_not_exists: true

    # Certificate verified_at for recent activity
    add_index :certificates, :verified_at, if_not_exists: true

    # Certificate created_at for ordering
    add_index :certificates, :created_at, if_not_exists: true

    # Matrix requirements composite index for compliance queries
    add_index :matrix_requirements, [ :vessel_id, :role_id, :certificate_type_id ],
              name: "index_matrix_requirements_composite", unique: true, if_not_exists: true

    # Matrix requirements for quick lookups
    add_index :matrix_requirements, [ :vessel_id, :role_id ], name: "index_matrix_requirements_vessel_role", if_not_exists: true

    # Certificate request expires_at for cleanup jobs
    add_index :certificate_requests, :expires_at, if_not_exists: true

    # Vessel name for search
    add_index :vessels, "LOWER(name)", name: "index_vessels_on_lower_name", if_not_exists: true

    # Role position for ordering
    add_index :roles, :position, if_not_exists: true
  end
end
