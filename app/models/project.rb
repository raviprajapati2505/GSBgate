class Project < ActiveRecord::Base
  # reference to project owner
  belongs_to :owner, class_name: :User, foreign_key: "user_id"
  has_many :project_authorizations
  has_many :users, through: :project_authorizations

  belongs_to :project_status
end
