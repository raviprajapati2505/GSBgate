class CreateCertificationPathStatusesBis < ActiveRecord::Migration[4.2]
  def change
    create_table :certification_path_statuses do |t|
      t.string :name
      t.string :past_name
      t.text :description
      t.integer :context

      t.timestamps null: false
    end
    remove_column :certification_paths, :status
    add_reference :certification_paths, :certification_path_status, index: true
  end
end
