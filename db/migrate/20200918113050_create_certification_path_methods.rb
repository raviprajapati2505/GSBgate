class CreateCertificationPathMethods < ActiveRecord::Migration[5.2]
  def change
    create_table :certification_path_methods do |t|
      t.references :certification_path, foreign_key: true
      t.integer :assessment_method

      t.timestamps
    end
  end
end
