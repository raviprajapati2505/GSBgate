class AddCertificationDateToCertificationPath < ActiveRecord::Migration
  def change
    add_column :certification_paths, :certified_at, :datetime
  end
end
