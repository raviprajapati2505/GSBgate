class RemoveWaitingForColumn < ActiveRecord::Migration
  def change
    remove_column :certification_path_statuses, :waiting_for
  end
end
