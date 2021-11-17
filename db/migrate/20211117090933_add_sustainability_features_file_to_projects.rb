class AddSustainabilityFeaturesFileToProjects < ActiveRecord::Migration[5.2]
  def change
    add_column :projects, :sustainability_features_file, :string
  end
end
