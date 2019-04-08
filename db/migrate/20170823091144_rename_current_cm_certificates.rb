class RenameCurrentCmCertificates < ActiveRecord::Migration[4.2]
  def change
    Certificate.where(certificate_type: 1, gsas_version: '2.1').update_all(gsas_version: '2.1 issue 1')
  end
end
