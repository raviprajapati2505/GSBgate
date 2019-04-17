class AddServiceProviderToProject < ActiveRecord::Migration[4.2]
  def change
    add_column :projects, :service_provider, :string, null: false, default: ''
  end
end
