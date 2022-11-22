class AddBuildingsNumberToCertificationPath < ActiveRecord::Migration[5.2]
  def change
    add_column :certification_paths, :buildings_number, :integer, default: 0
  end
end
