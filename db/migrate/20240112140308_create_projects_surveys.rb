class CreateProjectsSurveys < ActiveRecord::Migration[7.0]
  def change
    create_table :projects_surveys do |t|
      t.references :project, foreign_key: true
      t.references :survey_type, foreign_key: true
      t.references :survey_questionnaire_version, foreign_key: true, index: true
      t.string :title
      t.string :slug, index: true, unique: true
      t.integer :status
      t.date :end_date
      t.integer :user_access
      t.string :description
      t.string :submission_statement
      t.datetime :released_at
    end
  end
end
