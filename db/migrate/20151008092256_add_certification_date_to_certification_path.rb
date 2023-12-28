class AddCertificationDateToCertificationPath < ActiveRecord::Migration[4.2]
  def change
    add_column :certification_paths, :certified_at, :datetime
  end
end
