class AlterScoreToLinkToSchemeCriterion < ActiveRecord::Migration
  def change
    remove_index :scores, :criterion_id
    remove_column :scores, :criterion_id
    add_column :scores, :scheme_criterion_id, :integer
    add_index :scores, :scheme_criterion_id
  end
end
