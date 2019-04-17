class RenameCriteriaStatusLogTable < ActiveRecord::Migration[4.2]
  def change
    rename_table :criteria_status_logs, :scheme_mix_criterion_logs
  end
end
