class AddShowAllCrit < ActiveRecord::Migration
  def change
    add_column :certification_paths, :show_all_criteria, :boolean, default: true
  end
end
