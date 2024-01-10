class CreateQuestionOptions < ActiveRecord::Migration[7.0]
  def change
    create_table :question_options do |t|
      t.integer :position, default: 0
      t.text :option_text
      t.float :score, default: 0.0
      t.references :survey_question, foreign_key: true

      t.timestamps
    end
  end
end
