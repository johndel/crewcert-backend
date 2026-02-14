class AddCertificateNumberToCertificates < ActiveRecord::Migration[8.1]
  def change
    add_column :certificates, :certificate_number, :string
  end
end
