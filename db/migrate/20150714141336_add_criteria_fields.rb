class AddCriteriaFields < ActiveRecord::Migration
  def change
    add_column :criteria, :description, :string
    add_column :criteria, :measurement, :string
    add_column :criteria, :measurement_principle, :string
  end
end
