class CreateDemeritFlags < ActiveRecord::Migration[5.2]
  def change
    create_table :demerit_flags do |t|
      t.string :points
      t.references :user, index: true, foreign_key: true
      t.string :gsas_trust_notification
      t.string :practitioner_acknowledge
      t.timestamps
    end
    remove_column :users, :demerit_flag
    remove_column :users, :demerit_points
    remove_column :users, :demerit_flag_updated_at
  end
end
