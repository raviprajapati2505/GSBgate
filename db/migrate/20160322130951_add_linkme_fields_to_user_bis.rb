class AddLinkmeFieldsToUserBis < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :gsas_trust_team, :boolean, null: false, default: false
    add_column :users, :cgp_license, :boolean, null: false, default: false
  end
end
