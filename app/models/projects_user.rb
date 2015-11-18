class ProjectsUser < ActiveRecord::Base
  include Auditable
  include Taskable

  belongs_to :user
  belongs_to :project

  enum role: { project_team_member: 0, project_manager: 1, enterprise_account: 2, certifier: 3, certifier_manager: 4 }

  validates :role, inclusion: ProjectsUser.roles.keys
  validates_presence_of :user
  validates :user, uniqueness: {scope:[:project, :role]}

  scope :for_project, ->(project) {
    where(project: project)
  }

  scope :for_user, ->(user) {
    where(user: user)
  }

  scope :assessors, -> {
    where(role: [ProjectsUser.roles[:project_team_member], ProjectsUser.roles[:project_manager], ProjectsUser.roles[:enterprise_account]])
  }

  scope :assessor_managers, -> {
    where(role: ProjectsUser.roles[:project_manager])
  }

  scope :certifiers, -> {
    where(role: [ProjectsUser.roles[:certifier], ProjectsUser.roles[:certifier_manager]])
  }

  scope :certifier_managers, -> {
    where(role: ProjectsUser.roles[:certifier_manager])
  }

end
