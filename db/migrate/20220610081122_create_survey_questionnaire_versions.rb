class CreateSurveyQuestionnaireVersions < ActiveRecord::Migration[5.2]
  def change
    create_table :survey_questionnaire_versions do |t|
      t.integer :version, null: false, default: 0
      t.datetime :released_at
      t.references :survey_type, foreign_key: true

      t.timestamps
    end
  end
end
