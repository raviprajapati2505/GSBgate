class AddSignedByMngrToCertificatePath < ActiveRecord::Migration[4.2]
  def change
    add_column :certification_paths, :signed_by_mngr, :boolean, default: false
    add_column :certification_paths, :signed_by_top_mngr, :boolean, default: false
  end
end
