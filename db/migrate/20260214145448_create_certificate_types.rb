class CreateCertificateTypes < ActiveRecord::Migration[8.1]
  def change
    create_table :certificate_types do |t|
      t.string :code, null: false
      t.string :name, null: false
      t.text :description
      t.integer :validity_period_months

      t.timestamps
    end

    add_index :certificate_types, :code, unique: true
  end
end
