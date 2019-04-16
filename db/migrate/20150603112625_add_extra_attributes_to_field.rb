class AddExtraAttributesToField < ActiveRecord::Migration[4.2]
  def change
    add_column :fields, :required, :boolean
    add_column :fields, :help_text, :text
    add_column :fields, :prefix, :string
    add_column :fields, :suffix, :string
  end
end
