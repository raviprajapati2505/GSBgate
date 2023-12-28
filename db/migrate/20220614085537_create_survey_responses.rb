class CreateSurveyResponses < ActiveRecord::Migration[5.2]
  def change 
    create_table :survey_responses do |t|
      t.string :name
      t.string :email
      t.references :projects_survey, foreign_key: true
      t.timestamps
    end
  end
end
