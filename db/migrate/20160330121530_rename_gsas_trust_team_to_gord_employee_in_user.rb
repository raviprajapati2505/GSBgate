class RenameGsasTrustTeamToGordEmployeeInUser < ActiveRecord::Migration[4.2]
  def change
    rename_column :users, :gsas_trust_team, :gord_employee
  end
end
