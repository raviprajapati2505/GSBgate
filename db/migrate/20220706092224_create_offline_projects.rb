class CreateOfflineProjects < ActiveRecord::Migration[5.2]
  def up
    create_table :offline_projects do |t|
      t.string :code
      t.string :name
      t.string :certified_area
      t.string :plot_area
      t.integer :certificate_type
      t.string :developer
      t.string :construction_year
      t.text :description
      t.string :loc_as_per_directory
      t.string :owner
      t.integer :assessment_type, default: 0
      t.timestamps
    end

    create_table :offline_project_documents do |t|
      t.references :offline_project, foreign_key: true
      t.string :document_file
      t.timestamps
    end

    create_table :offline_certification_paths do |t|
      t.references :offline_project, foreign_key: true
      t.string :name
      t.integer :version
      t.string :development_type
      t.string :certified_at
      t.string :status
      t.integer :rating
      t.string :score
      t.timestamps
    end

    create_table :offline_scheme_mixes do |t|
      t.references :offline_certification_path, foreign_key: true
      t.string :name
      t.decimal :weight
      t.timestamps
    end

    create_table :offline_scheme_mix_criteria do |t|
      t.references :offline_scheme_mix, foreign_key: true
      t.string :name
      t.string :code
      t.decimal :score
      t.timestamps
    end
    
  end

  def down
    drop_table :offline_projects, force: :cascade
    drop_table :offline_project_documents, force: :cascade 
    drop_table :offline_certification_paths, force: :cascade 
    drop_table :offline_scheme_mixes, force: :cascade 
    drop_table :offline_scheme_mix_criteria, force: :cascade 
  end
end
