class AddDevelopmentTypeToCertificationPath < ActiveRecord::Migration[4.2]
  def change
    add_column :certification_paths, :development_type, :integer
  end
end
