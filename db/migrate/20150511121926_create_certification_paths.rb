class CreateCertificationPaths < ActiveRecord::Migration
  def change
    create_table :certification_paths do |t|
      t.references :project, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
