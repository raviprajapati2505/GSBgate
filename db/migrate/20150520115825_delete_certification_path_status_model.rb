class DeleteCertificationPathStatusModel < ActiveRecord::Migration
  def change
    drop_table :certification_path_statuses
    add_column :certification_paths, :status, :integer
  end
end
