class AddStatusToSchemeMixCriteria < ActiveRecord::Migration[4.2]
  def change
    add_column :scheme_mix_criteria, :status, :integer
    add_column :scheme_mix_criteria, :achieved_score, :integer
  end
end
