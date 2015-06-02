class ProjectAuthorization < ActiveRecord::Base
  belongs_to :user
  belongs_to :project
  belongs_to :requirement_datum

  enum permission: [ :read_only, :read_and_write, :manage ]

  validates :permission, inclusion: ProjectAuthorization.permissions.keys
end
