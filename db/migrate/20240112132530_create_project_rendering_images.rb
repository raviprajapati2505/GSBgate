class CreateProjectRenderingImages < ActiveRecord::Migration[7.0]
  def change
    create_table :project_rendering_images do |t|
      t.string :rendering_image
      t.references :certification_path, foreign_key: true
      t.references :project, foreign_key: true

      t.timestamps
    end
  end
end
