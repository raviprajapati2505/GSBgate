class RequirementDatum < ActiveRecord::Base
  has_many :scheme_mix_criteria_requirement_data
  has_many :scheme_mix_criteria, through: :scheme_mix_criteria_requirement_data
  belongs_to :reportable_data, polymorphic: true
  belongs_to :requirement
  has_one :project_authorization

  enum status: [ :required, :provided, :not_required ]

  before_validation :assign_default_status, on: :create

  validates :status, inclusion: RequirementDatum.statuses.keys

  scope :provided, -> {
    where(status: 1)
  }

  scope :for_user, ->(user) {
    includes(:project_authorization).where(project_authorizations: {user_id: user.id})
  }

  scope :for_project, ->(project) {
    includes(:scheme_mix_criteria => [:scheme_mix => [:certification_path]]).where(certification_paths: {project_id: project.id})
  }

  scope :for_category, ->(category) {
    includes(:scheme_mix_criteria => [:scheme_criterion => [:criterion]]).where(criteria: {category_id: category.id})
  }

  scope :owned_by_user, ->(user) {
    joins(:scheme_mix_criteria => [:scheme_mix => [:certification_path => [:project]]]).where(projects: {owner_id: user.id})
  }

  scope :managed_by_user, ->(user) {
     joins(:scheme_mix_criteria => [:scheme_mix => [:certification_path => [:project => [:project_authorizations]]]]).where(project_authorizations: {user_id: user.id, permission: ['manage', ProjectAuthorization.permissions[:manage]]})
  }

  scope :updateable_by_user, ->(user) {
    owned_by_user(user) | managed_by_user(user) | for_user(user)
  }

  scope :for_scheme_mix, ->(scheme_mix) {
    includes(:scheme_mix_criteria).where(scheme_mix_criteria: {scheme_mix: scheme_mix})
  }

  private
  def assign_default_status
    self.status = :required if self.status.nil?
  end

end
