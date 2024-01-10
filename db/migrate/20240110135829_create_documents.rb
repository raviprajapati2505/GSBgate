class CreateDocuments < ActiveRecord::Migration[7.0]
  def change
    create_table :documents do |t|
      t.string :document_file
      t.string :type
      t.text :store_dir
      t.references :user, foreign_key: true, index: true
      t.references :certification_path, foreign_key: true, index: true
      t.references :certification_path_status, foreign_key: true, index: true

      t.timestamps null: false
    end

    add_index(:documents, :user_id, name: 'by_user')
  end
end
