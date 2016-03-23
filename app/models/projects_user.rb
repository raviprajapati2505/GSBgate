class ProjectsUser < ActiveRecord::Base
  include Auditable
  include Taskable

  belongs_to :user
  belongs_to :project

  enum role: { project_team_member: 0, cgp_project_manager: 1, enterprise_client: 2, certifier: 3, certification_manager: 4 }

  validates :role, inclusion: ProjectsUser.roles.keys
  validates_presence_of :user
  validates :user, uniqueness: {scope:[:project, :role]}

  scope :for_project, ->(project) {
    where(project: project)
  }

  scope :for_user, ->(user) {
    where(user: user)
  }

  scope :project_team, -> {
    where(role: [ProjectsUser.roles[:project_team_member], ProjectsUser.roles[:cgp_project_manager]])
  }

  scope :cgp_project_managers, -> {
    where(role: ProjectsUser.roles[:cgp_project_manager])
  }

  scope :gsas_trust_team, -> {
    where(role: [ProjectsUser.roles[:certifier], ProjectsUser.roles[:certification_manager]])
  }

  scope :certification_managers, -> {
    where(role: ProjectsUser.roles[:certification_manager])
  }

  scope :enterprise_clients, -> {
    where(role: ProjectsUser.roles[:enterprise_client])
  }

  def project_team?
    self.project_team_member? || self.cgp_project_manager?
  end

  def gsas_trust_team?
    self.certifier? || self.certification_manager?
  end
end
