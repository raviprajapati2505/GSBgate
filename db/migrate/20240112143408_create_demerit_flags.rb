class CreateDemeritFlags < ActiveRecord::Migration[7.0]
  def change
    create_table :demerit_flags do |t|
      t.string :points
      t.references :user, index: true, foreign_key: true
      t.string :gsas_trust_notification
      t.string :practitioner_acknowledge

      t.timestamps
    end
  end
end
