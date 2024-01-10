class CreateQuestionResponses < ActiveRecord::Migration[7.0]
  def change
    create_table :question_responses do |t|
      t.string :value
      t.references :survey_question, foreign_key: true
      t.references :survey_response, foreign_key: true

      t.timestamps
    end
  end
end
