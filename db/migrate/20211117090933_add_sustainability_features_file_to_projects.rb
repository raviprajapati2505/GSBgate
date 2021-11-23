class AddSustainabilityFeaturesFileToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :sustainability_features_file, :string
    add_column :projects, :area_statement_file, :string
  end
end
