class RemoveWaitingForColumn < ActiveRecord::Migration[4.2]
  def change
    remove_column :certification_path_statuses, :waiting_for, :integer
  end
end
