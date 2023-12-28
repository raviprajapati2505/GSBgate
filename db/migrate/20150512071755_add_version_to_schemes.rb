class AddVersionToSchemes < ActiveRecord::Migration[4.2]
  def change
    add_column :schemes, :version, :string
  end
end
