class AddWaitingForToCertificationPathStatus < ActiveRecord::Migration[4.2]
  def change
    remove_column :certification_path_statuses, :context
    add_column :certification_path_statuses, :waiting_for, :integer
  end
end
