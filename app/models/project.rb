class Project < ActiveRecord::Base
  # reference to project owner
  belongs_to :user
  has_many :project_authorizations
  has_many :users, through: :project_authorizations

  def get_owner
    return user
  end

end
