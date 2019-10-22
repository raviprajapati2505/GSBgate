class SeedCm2019 < ActiveRecord::Migration[5.2]
  def change
    add_column :requirements, :display_weight, :integer
  end
end
