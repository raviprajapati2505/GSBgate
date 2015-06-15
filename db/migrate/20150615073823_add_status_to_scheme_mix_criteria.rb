class AddStatusToSchemeMixCriteria < ActiveRecord::Migration
  def change
    add_column :scheme_mix_criteria, :status, :integer
    add_column :scheme_mix_criteria, :achieved_score, :integer
  end
end
