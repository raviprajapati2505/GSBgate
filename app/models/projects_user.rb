class ProjectsUser < ActiveRecord::Base
  include Auditable
  include Taskable

  belongs_to :user
  belongs_to :project

  enum role: { project_team_member: 0, project_manager: 1, enterprise_account: 2, certifier: 3, certifier_manager: 4 }

  validates :role, inclusion: ProjectsUser.roles.keys

  scope :for_project, ->(project) {
    where(project: project)
  }

  scope :for_user, ->(user) {
    where(user: user)
  }
end
