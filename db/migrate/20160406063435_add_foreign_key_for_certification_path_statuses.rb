class AddForeignKeyForCertificationPathStatuses < ActiveRecord::Migration
  def change
    add_foreign_key(:certification_paths, :certification_path_statuses)
  end
end
