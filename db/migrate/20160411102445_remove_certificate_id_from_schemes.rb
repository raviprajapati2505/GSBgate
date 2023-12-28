class RemoveCertificateIdFromSchemes < ActiveRecord::Migration[4.2]
  def change
    remove_column :schemes, :certificate_id
  end
end
