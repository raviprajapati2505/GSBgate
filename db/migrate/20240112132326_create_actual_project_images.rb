class CreateActualProjectImages < ActiveRecord::Migration[7.0]
  def change
    create_table :actual_project_images do |t|
      t.string :actual_image
      t.references :project, foreign_key: true
      t.references :certification_path, foreign_key: true

      t.timestamps
    end
  end
end
