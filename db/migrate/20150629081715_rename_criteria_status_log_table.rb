class RenameCriteriaStatusLogTable < ActiveRecord::Migration
  def change
    rename_table :criteria_status_logs, :scheme_mix_criterion_logs
  end
end
