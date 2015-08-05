class AddConstructionYearToProject < ActiveRecord::Migration
  def change
    add_column :projects, :construction_year, :integer
  end
end
