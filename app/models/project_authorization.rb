class ProjectAuthorization < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  belongs_to :requirement_datum

  enum permission: [ :read_only, :read_write ]

  enum role: [ :project_team_member, :cgp_project_manager, :enterprise_account, :project_system_administrator ]

  validates :permission, inclusion: ProjectAuthorization.permissions.keys

  # validates :role, inclusion: ProjectAuthorization.roles.keys

  scope :for_requirement_datum, -> {
    where('requirement_datum_id = requirement_data.id')
  }
end
