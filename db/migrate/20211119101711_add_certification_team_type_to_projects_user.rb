class AddCertificationTeamTypeToProjectsUser < ActiveRecord::Migration[5.2]
  def change
    add_column :projects_users, :certification_team_type, :integer, default: 0
  end
end
