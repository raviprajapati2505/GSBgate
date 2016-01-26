class CreateBackgroundExecution < ActiveRecord::Migration
  def change
    create_table :background_executions do |t|
      t.string :name

      t.timestamps null:false
    end
  end
end
