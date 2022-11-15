class AddNominatedCgpToServiceProviderDetailsTable < ActiveRecord::Migration[5.2]
  def change
    add_column :service_provider_details, :nominated_cgp, :string
  end
end
