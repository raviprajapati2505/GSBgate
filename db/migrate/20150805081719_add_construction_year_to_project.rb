class AddConstructionYearToProject < ActiveRecord::Migration[4.2]
  def change
    add_column :projects, :construction_year, :integer
  end
end
