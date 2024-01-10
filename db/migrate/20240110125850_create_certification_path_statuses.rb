class CreateCertificationPathStatuses < ActiveRecord::Migration[7.0]
  def change
    create_table :certification_path_statuses do |t|
      t.string :name
      t.string :past_name
      t.text :description

      t.timestamps null: false
    end
  end
end
