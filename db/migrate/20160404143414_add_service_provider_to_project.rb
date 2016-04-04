class AddServiceProviderToProject < ActiveRecord::Migration
  def change
    add_column :projects, :service_provider, :string, null: false, default: ''
  end
end
