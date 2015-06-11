class ProjectAuthorization < ActiveRecord::Base
  belongs_to :user
  belongs_to :project

  enum role: [ :project_team_member, :cgp_project_manager, :enterprise_account, :project_system_administrator ]

  validates :role, inclusion: ProjectAuthorization.roles.keys

end
