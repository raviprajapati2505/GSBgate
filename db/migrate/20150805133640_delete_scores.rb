class DeleteScores < ActiveRecord::Migration[4.2]
  def change
    drop_table(:scores)
  end
end
