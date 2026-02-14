class CreateVessels < ActiveRecord::Migration[8.1]
  def change
    create_table :vessels do |t|
      t.string :name, null: false
      t.string :imo
      t.string :management_company

      t.timestamps
    end

    add_index :vessels, :imo, unique: true, where: "imo IS NOT NULL"
  end
end
