class CreateCertificationPathStatuses < ActiveRecord::Migration[4.2]
  def change
    create_table :certification_path_statuses do |t|
      t.string :label
      t.timestamps null: false
    end
  end
end
