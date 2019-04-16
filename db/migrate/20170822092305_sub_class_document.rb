class SubClassDocument < ActiveRecord::Migration[4.2]
  def change
    change_table :documents do |t|
      t.column :type, :string
      t.references :certification_path, index:true, foreign_key: true
    end
  end
end
