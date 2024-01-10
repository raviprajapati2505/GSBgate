class CreateSchemeMixCriterionBoxes < ActiveRecord::Migration[7.0]
  def change
    create_table :scheme_mix_criterion_boxes do |t|
      t.references :scheme_mix_criterion, foreign_key: true
      t.references :scheme_criterion_box, foreign_key: true
      t.boolean :is_checked

      t.timestamps
    end
  end
end
