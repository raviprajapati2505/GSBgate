class CreateSurveyQuestions < ActiveRecord::Migration[7.0]
  def change
    create_table :survey_questions do |t|
      t.string :question_text
      t.text :description
      t.boolean :mandatory, default: false
      t.integer :position, default: 0
      t.string :question_type
      t.references :survey_questionnaire_version, foreign_key: true

      t.timestamps
    end
  end
end
