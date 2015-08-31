class UserTask < ActiveRecord::Base
  belongs_to :user
  belongs_to :project

  # validates :role, inclusion: User.roles.keys
  # validates :project_role, inclusion: ProjectAuthorization.roles.keys
end
