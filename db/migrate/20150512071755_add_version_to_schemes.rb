class AddVersionToSchemes < ActiveRecord::Migration
  def change
    add_column :schemes, :version, :string
  end
end
