class RemoveCertificateIdFromSchemes < ActiveRecord::Migration
  def change
    remove_column :schemes, :certificate_id
  end
end
