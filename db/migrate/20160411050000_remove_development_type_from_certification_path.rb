class RemoveDevelopmentTypeFromCertificationPath < ActiveRecord::Migration[4.2]
  def change
    remove_column :certification_paths, :development_type
  end
end
