class CreateSurveyTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :survey_types do |t|
      t.string :title
      t.string :description

      t.timestamps
    end
  end
end
