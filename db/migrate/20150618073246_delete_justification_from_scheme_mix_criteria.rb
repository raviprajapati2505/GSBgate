class DeleteJustificationFromSchemeMixCriteria < ActiveRecord::Migration
  def change
    remove_column :scheme_mix_criteria, :justification, :text
    create_table :criteria_status_logs do |t|
      t.text :comment
      t.integer :old_status
      t.integer :new_status
      t.references :scheme_mix_criterion, index: true, foreign_key: true
      t.references :user, index: true, foreign_key: true
      t.timestamps null: false
    end
  end
end
