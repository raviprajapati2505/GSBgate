class ProjectAuthorization < ActiveRecord::Base
  belongs_to :user
  belongs_to :project

  enum role: [ :project_team_member, :cgp_project_manager, :enterprise_account, :project_system_administrator, :certifier, :certifier_manager ]

  validates :role, inclusion: ProjectAuthorization.roles.keys

  scope :for_project, ->(project) {
    where(project: project)
  }

  scope :for_user, ->(user) {
    where(user: user)
  }
end
