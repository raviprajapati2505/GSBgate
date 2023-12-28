class AddCertificateIdToCertificationPaths < ActiveRecord::Migration[4.2]
  def change
    add_column :certification_paths, :certificate_id, :integer, :references => 'certificates'
  end
end
