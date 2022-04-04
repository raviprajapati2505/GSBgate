class AddServiceProvideToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :service_provider_id, :integer, null: true, index: true
    add_foreign_key :users, :users, column: :service_provider_id
  end
end
