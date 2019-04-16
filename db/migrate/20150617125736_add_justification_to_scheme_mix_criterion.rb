class AddJustificationToSchemeMixCriterion < ActiveRecord::Migration[4.2]
  def change
    add_column :scheme_mix_criteria, :justification, :text
  end
end
