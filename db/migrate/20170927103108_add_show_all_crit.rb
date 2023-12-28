class AddShowAllCrit < ActiveRecord::Migration[4.2]
  def change
    add_column :certification_paths, :show_all_criteria, :boolean, default: true
  end
end
