class ProjectAuthorization < ActiveRecord::Base
  belongs_to :user, dependent: :destroy
  belongs_to :project, dependent: :destroy

  # TODO list of possible categories is dependent on project type (office building, school, ...)
  CATEGORIES = [ 'All', 'Cultural & Economic Value', 'Energy', 'Indoor Environment', 'Management & Operations', 'Materials', 'Site', 'Urban Connectivity', 'Water']

  enum permission: [ :read_only, :read_and_write, :manage ]

  validates :category, inclusion: CATEGORIES

  before_destroy :prevent_destroy_owner

  private
  def prevent_destroy_owner
    if project.owner == user
      raise 'Can\'t destroy project owner'
    end
  end
end
