class AddSurveyQuestionnaireReferenceToProjectsSurvey < ActiveRecord::Migration[5.2]
  def change
    add_reference :projects_surveys, :survey_questionnaire_version, index: true, foreign_key: true
  end
end
