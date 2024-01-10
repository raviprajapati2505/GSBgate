class CreateArchives < ActiveRecord::Migration[7.0]
  def change
    create_table :archives do |t|
      t.string :archive_file
      t.integer :status
      t.text :criterion_document_ids, array: true, default: []
      t.boolean :all_criterion_document, default: false
      t.references :subject, polymorphic: true, index: true
      t.references :user, foreign_key: true, index: true

      t.timestamps null: false
    end
  end
end
