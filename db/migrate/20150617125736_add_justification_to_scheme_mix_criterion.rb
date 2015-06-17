class AddJustificationToSchemeMixCriterion < ActiveRecord::Migration
  def change
    add_column :scheme_mix_criteria, :justification, :text
  end
end
