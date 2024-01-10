class CreateProjects < ActiveRecord::Migration[7.0]
  def change
    create_table :projects do |t|
      t.string :name
      t.string :code
      t.string :city
      t.string :district
      t.string :service_provider_2
      t.string :estimated_project_cost
      t.string :cost_square_meter
      t.string :estimated_building_cost
      t.string :estimated_infrastructure_cost
      t.string :coordinates
      t.text :description
      t.text :address
      t.string :location
      t.string :country
      t.string :developer
      t.integer :gross_area
      t.integer :certified_area
      t.integer :carpark_area
      t.integer :project_site_area
      t.integer :construction_year
      t.integer :certificate_type
      t.integer :buildings_footprint_area
      t.integer :project_owner_business_sector
      t.integer :project_developer_business_sector
      t.string :location_plan_file
      t.string :site_plan_file
      t.string :design_brief_file
      t.string :project_narrative_file
      t.string :sustainability_features_file
      t.string :area_statement_file
      t.string :owner, null: false, default: ''
      t.string :service_provider, null: false, default: ''
      t.string :project_owner_email
      t.string :specify_other_project_use

      t.references :building_type_group, foreign_key: true, index: true
      t.references :building_type, foreign_key: true, index: true

      t.timestamps null: false
    end
  end
end
