class RemoveSignedByManagementFromCertificationPath < ActiveRecord::Migration
  def change
    remove_column :certification_paths, :signed_by_mngr
    remove_column :certification_paths, :signed_by_top_mngr
  end
end
