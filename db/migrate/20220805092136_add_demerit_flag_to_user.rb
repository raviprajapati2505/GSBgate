class AddDemeritFlagToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :demerit_flag, :integer, default: 0
    add_column :users, :demerit_points, :integer, default: 0
    add_column :users, :demerit_flag_updated_at, :date
  end
end
