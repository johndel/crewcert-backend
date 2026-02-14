class CreateCertificateRequests < ActiveRecord::Migration[8.1]
  def change
    create_table :certificate_requests do |t|
      t.references :crew_member, null: false, foreign_key: true
      t.string :token, null: false
      t.string :status, null: false, default: 'pending'
      t.datetime :sent_at
      t.datetime :submitted_at
      t.datetime :expires_at

      t.timestamps
    end

    add_index :certificate_requests, :token, unique: true
    add_index :certificate_requests, :status
  end
end
