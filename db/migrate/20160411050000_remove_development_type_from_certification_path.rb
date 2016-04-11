class RemoveDevelopmentTypeFromCertificationPath < ActiveRecord::Migration
  def change
    remove_column :certification_paths, :development_type
  end
end
