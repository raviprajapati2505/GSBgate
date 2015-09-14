class AddDevelopmentTypeToCertificationPath < ActiveRecord::Migration
  def change
    add_column :certification_paths, :development_type, :integer
  end
end
