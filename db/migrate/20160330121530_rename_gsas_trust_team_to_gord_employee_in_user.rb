class RenameGsasTrustTeamToGordEmployeeInUser < ActiveRecord::Migration
  def change
    rename_column :users, :gsas_trust_team, :gord_employee
  end
end
