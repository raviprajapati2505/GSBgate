class CreateCertificationPaths < ActiveRecord::Migration[7.0]
  def change
    create_table :certification_paths do |t|
      t.references :project, foreign_key: true, index: true
      t.references :certificate, foreign_key: true, index: true
      t.references :certification_path_status, foreign_key: true, index: true
      t.datetime :expires_at
      t.datetime :certified_at
      t.integer :max_review_count, default: 2
      t.integer :assessment_method, default: 0
      t.integer :buildings_number, default: 0
      t.string :signed_certificate_file
      t.datetime :started_at
      t.boolean :pcr_track, default: false
      t.boolean :appealed, default: false
      t.boolean :main_scheme_mix_selected, default: false
      t.boolean :show_all_criteria, default: true

      t.timestamps null: false
    end
  end
end
