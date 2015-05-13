class AddCertificateIdToCertificationPaths < ActiveRecord::Migration
  def change
    add_column :certification_paths, :certificate_id, :integer, :references => 'certificates'
  end
end
