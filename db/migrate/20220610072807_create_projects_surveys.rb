class CreateProjectsSurveys < ActiveRecord::Migration[5.2]
  def change
    create_table :projects_surveys do |t|
      t.references :project, foreign_key: true
      t.references :survey_type, foreign_key: true
      t.string :title
      t.integer :status
      t.date :end_date
      t.integer :user_access
      t.string :description
      t.string :submission_statement
      t.datetime :released_at
    end
  end
end
