class AddSignedCertificateFileToOfflineCertificationPath < ActiveRecord::Migration[5.2]
  def change
    add_column :offline_certification_paths, :signed_certificate_file, :string
  end
end
