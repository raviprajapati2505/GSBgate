class CreateCertificates < ActiveRecord::Migration[7.0]
  def change
    create_table :certificates do |t|
      t.string :name
      t.string :gsas_version
      t.integer :certificate_type
      t.integer :assessment_stage
      t.integer :display_weight
      t.integer :certification_type

      t.timestamps null: false
    end
  end
end
