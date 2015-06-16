class CreateDocumentsBis < ActiveRecord::Migration
  def change
    create_table :documents do |t|
      t.string :document_file
      t.references :user, index: true, foreign_key: true

      t.timestamps null: false
    end

    add_index(:documents, :user_id, unique: true, name: 'by_user')
  end
end
