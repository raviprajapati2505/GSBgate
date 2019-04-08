class AddForeignKeyForCertificationPathStatuses < ActiveRecord::Migration[4.2]
  def change
    add_foreign_key(:certification_paths, :certification_path_statuses)
  end
end
