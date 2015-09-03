class ProjectsUser < AuditableRecord
  belongs_to :user
  belongs_to :project

  enum role: [ :project_team_member, :project_manager, :enterprise_account, :certifier, :certifier_manager ]

  validates :role, inclusion: ProjectsUser.roles.keys

  scope :for_project, ->(project) {
    where(project: project)
  }

  scope :for_user, ->(user) {
    where(user: user)
  }
end
