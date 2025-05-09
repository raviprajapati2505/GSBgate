class ProjectsUser < ApplicationRecord
  include Auditable
  include Taskable

  belongs_to :user, optional: true
  belongs_to :project, optional: true

  enum role: { project_team_member: 5, cgp_project_manager: 1, enterprise_client: 2, certifier: 3, certification_manager: 4 }
  enum certification_team_type: [ :other ]

  validates :role, inclusion: ProjectsUser.roles.keys
  validates_presence_of :user
  validates :user, uniqueness: {scope:[:project, :role, :certification_team_type]}

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
    joins(:user).where(role: ProjectsUser.roles[:cgp_project_manager]).order("users.name")
  }

  scope :gsb_team, -> {
    where(role: [ProjectsUser.roles[:certifier], ProjectsUser.roles[:certification_manager]])
  }

  scope :certification_managers, -> {
    joins(:user).where(role: ProjectsUser.roles[:certification_manager]).order("users.name")
  }

  scope :project_team_with_type, ->(certification_team_type) {
    where(role: [ProjectsUser.roles[:project_team_member], ProjectsUser.roles[:cgp_project_manager]], certification_team_type: certification_team_type)
  }

  scope :gsb_team_with_type, ->(certification_team_type) {
    where(role: [ProjectsUser.roles[:certifier], ProjectsUser.roles[:certification_manager]], certification_team_type: certification_team_type)
  }

  scope :enterprise_clients, -> {
    joins(:user).where(role: ProjectsUser.roles[:enterprise_client]).order("users.name")
  }

  def project_team?
    self.project_team_member? || self.cgp_project_manager?
  end

  def gsb_team?
    self.certifier? || self.certification_manager?
  end

  def self.with_role(role)
    where(role: role)
  end

  def self.group_by_roles
    project_users = []
    roles = pluck(:role).uniq
    roles&.each do |role|
      project_users.push(*where(role: role)&.to_a)
    end
    return project_users
  end

  def self.projects_user_role(title = nil)
    roles = pluck(:role).uniq
    order = case title
             when "Practitioners"
              ["cgp_project_manager", "project_team_member"]
            when "GSB"
              ["certification_manager", "certifier"]
            when "Enterprise Clients"
              ["enterprise_client"]
            else
              []
            end

    return roles.sort_by { |e| order.index(e) || Float::INFINITY }
  end
end