class CreateMatrixRequirements < ActiveRecord::Migration[8.1]
  def change
    create_table :matrix_requirements do |t|
      t.references :vessel, null: false, foreign_key: true
      t.references :role, null: false, foreign_key: true
      t.references :certificate_type, null: false, foreign_key: true
      t.string :requirement_level, null: false

      t.timestamps
    end

    add_index :matrix_requirements, [ :vessel_id, :role_id, :certificate_type_id ], unique: true, name: 'idx_matrix_requirements_unique'
  end
end
