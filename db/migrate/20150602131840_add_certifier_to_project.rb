class AddCertifierToProject < ActiveRecord::Migration[4.2]
  def change
    add_reference :projects, :certifier, references: :users
    add_foreign_key :projects, :users, column: :owner_id
    add_foreign_key :projects, :users, column: :client_id
    add_foreign_key :projects, :users, column: :certifier_id
  end
end
