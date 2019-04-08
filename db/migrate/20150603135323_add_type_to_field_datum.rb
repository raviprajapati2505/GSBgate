class AddTypeToFieldDatum < ActiveRecord::Migration[4.2]
  def change
    add_column :field_data, :type, :string
  end
end
