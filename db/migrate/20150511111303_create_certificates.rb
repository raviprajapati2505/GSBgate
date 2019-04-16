class CreateCertificates < ActiveRecord::Migration[4.2]
  def change
    create_table :certificates do |t|
      t.string :label
      t.integer :certificate_type
      t.integer :assessment_stage

      t.timestamps null: false
    end
  end
end
