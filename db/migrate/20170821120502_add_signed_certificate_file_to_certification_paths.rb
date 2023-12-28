class AddSignedCertificateFileToCertificationPaths < ActiveRecord::Migration[4.2]
  def change
    add_column :certification_paths, :signed_certificate_file, :string
  end
end
