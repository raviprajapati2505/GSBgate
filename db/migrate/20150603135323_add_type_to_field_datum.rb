class AddTypeToFieldDatum < ActiveRecord::Migration
  def change
    add_column :field_data, :type, :string
  end
end
