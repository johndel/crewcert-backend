class CreateCertificates < ActiveRecord::Migration[8.1]
  def change
    create_table :certificates do |t|
      t.references :crew_member, null: false, foreign_key: true
      t.references :certificate_type, null: false, foreign_key: true
      t.date :issue_date
      t.date :expiry_date
      t.datetime :verified_at
      t.references :verified_by, null: true, foreign_key: { to_table: :users }
      t.jsonb :extracted_data, default: {}
      t.string :status, null: false, default: 'pending'

      t.timestamps
    end

    add_index :certificates, [ :crew_member_id, :certificate_type_id ]
    add_index :certificates, :status
    add_index :certificates, :expiry_date
  end
end
