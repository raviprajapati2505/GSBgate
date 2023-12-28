class CreateSchemeMixCriteria < ActiveRecord::Migration[4.2]
  def change
    create_table :scheme_mix_criteria do |t|
      t.integer :targeted_score
      t.references :scheme_mix, index: true, foreign_key: true
      t.references :scheme_criterion, index: true, foreign_key: true

      t.timestamps null: false
    end
  end
end
