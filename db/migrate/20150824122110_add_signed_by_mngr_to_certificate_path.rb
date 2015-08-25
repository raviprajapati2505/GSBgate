class AddSignedByMngrToCertificatePath < ActiveRecord::Migration
  def change
    add_column :certification_paths, :signed_by_mngr, :boolean, default: false
    add_column :certification_paths, :signed_by_top_mngr, :boolean, default: false
  end
end
