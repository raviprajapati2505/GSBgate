class AddCertificationTypeToSchemes < ActiveRecord::Migration[5.2]
  def up
    add_column :schemes, :certification_type, :integer
  end

  def down
    remove_column :schemes, :certification_type
  end
end
