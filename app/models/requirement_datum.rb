class RequirementDatum < ActiveRecord::Base
  has_many :scheme_mix_criteria_requirement_data
  has_many :scheme_mix_criteria, through: :scheme_mix_criteria_requirement_data
  belongs_to :reportable_data, polymorphic: true
  belongs_to :requirement
  belongs_to :user

  enum status: [ :required, :provided, :not_required ]

  before_validation :assign_default_status, on: :create

  validates :status, inclusion: RequirementDatum.statuses.keys

  scope :provided, -> {
    where(status: 1)
  }

  scope :assigned_to_user, ->(user) {
    where(user: user)
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

  scope :for_client, ->(user) {
    joins(:scheme_mix_criteria => [:scheme_mix => [:certification_path => [:project => [:project_authorizations]]]]).where(project_authorizations: {user_id: user.id, role: [ProjectAuthorization.roles[:enterprise_account]]})
  }

  scope :for_project_admin, ->(user) {
    joins(:scheme_mix_criteria => [:scheme_mix => [:certification_path => [:project => [:project_authorizations]]]]).where(project_authorizations: {user_id: user.id, role: [ProjectAuthorization.roles[:project_system_administrator]]})
  }

  scope :updateable_by_user, ->(user) {
    if user.system_admin?
      all
    else
      assigned_to_user(user) | for_client(user) | for_project_admin(user) | owned_by_user(user)
    end
  }

  scope :for_scheme_mix, ->(scheme_mix) {
    includes(:scheme_mix_criteria).where(scheme_mix_criteria: {scheme_mix: scheme_mix})
  }

  scope :unassigned, -> {
    where(user: nil)
  }

  private
  def assign_default_status
    self.status = :required if self.status.nil?
  end

end
