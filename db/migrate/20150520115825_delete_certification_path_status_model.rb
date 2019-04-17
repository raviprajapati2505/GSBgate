class DeleteCertificationPathStatusModel < ActiveRecord::Migration[4.2]
  def change
    drop_table :certification_path_statuses
    add_column :certification_paths, :status, :integer
  end
end
