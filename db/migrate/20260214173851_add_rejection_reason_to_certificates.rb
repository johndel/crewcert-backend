class AddRejectionReasonToCertificates < ActiveRecord::Migration[8.1]
  def change
    add_column :certificates, :rejection_reason, :text
  end
end
