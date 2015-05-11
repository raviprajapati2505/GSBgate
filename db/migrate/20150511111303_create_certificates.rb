class CreateCertificates < ActiveRecord::Migration
  def change
    create_table :certificates do |t|
      t.string :label
      t.integer :certificate_type
      t.integer :assessment_stage

      t.timestamps null: false
    end
  end
end
