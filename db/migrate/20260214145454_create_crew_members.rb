class CreateCrewMembers < ActiveRecord::Migration[8.1]
  def change
    create_table :crew_members do |t|
      t.references :vessel, null: false, foreign_key: true
      t.references :role, null: false, foreign_key: true
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :email, null: false
      t.string :phone

      t.timestamps
    end

    add_index :crew_members, :email
    add_index :crew_members, [ :vessel_id, :role_id ]
  end
end
