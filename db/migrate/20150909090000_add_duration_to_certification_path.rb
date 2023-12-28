class AddDurationToCertificationPath < ActiveRecord::Migration[4.2]
  def change
    add_column :certification_paths, :duration, :integer
    add_column :certification_paths, :started_at, :datetime
  end
end
