class AddSignedCertificateFileToCertificationPaths < ActiveRecord::Migration
  def change
    add_column :certification_paths, :signed_certificate_file, :string
  end
end
