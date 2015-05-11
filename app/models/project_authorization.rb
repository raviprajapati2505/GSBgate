class ProjectAuthorization < ActiveRecord::Base
  belongs_to :user, dependent: :destroy
  belongs_to :project, dependent: :destroy

  enum permission: [ :read_only, :read_and_write, :manage ]

  validates :permission, inclusion: ProjectAuthorization.permissions.keys
end
