class CreateLinkmeSurveys < ActiveRecord::Migration[7.0]
  def change
    create_table :linkme_surveys do |t|
      t.string :title
      t.string :status
      t.string :link
      t.string :user_access

      t.timestamps
    end
  end
end
