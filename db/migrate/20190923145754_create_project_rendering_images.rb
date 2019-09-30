class CreateProjectRenderingImages < ActiveRecord::Migration[5.2]
  def change
    create_table :project_rendering_images do |t|
      t.string :rendering_image
      t.references :project, foreign_key: true

      t.timestamps
    end
  end
end
