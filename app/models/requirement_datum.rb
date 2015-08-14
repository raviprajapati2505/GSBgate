class RequirementDatum < ActiveRecord::Base
  has_many :scheme_mix_criteria_requirement_data
  has_many :scheme_mix_criteria, through: :scheme_mix_criteria_requirement_data
  belongs_to :calculator_datum
  belongs_to :requirement
  belongs_to :user

  enum status: [ :required, :provided, :not_required ]

  before_validation :assign_default_status, on: :create

  validates :status, inclusion: RequirementDatum.statuses.keys

  default_scope {
    joins(:requirement)
    .order('requirements.label')
  }

  scope :completed, -> {
    provided | not_required
  }

  scope :assigned_to_user, ->(user) {
    where(user: user)
  }

  scope :not_assigned_to_user, ->(user) {
    where('(requirement_data.user_id <> %d) OR (requirement_data.user_id IS NULL)', user.id)
  }

  scope :for_project, ->(project) {
    includes(:scheme_mix_criteria => [:scheme_mix => [:certification_path]]).where(certification_paths: {project_id: project.id})
  }

  scope :for_category, ->(category) {
    includes(:scheme_mix_criteria => [:scheme_criterion => [:criterion]]).where(criteria: {category_id: category.id})
  }

  scope :for_scheme_mix, ->(scheme_mix) {
    includes(:scheme_mix_criteria).where(scheme_mix_criteria: {scheme_mix: scheme_mix})
  }

  scope :for_certification_path, ->(certification_path) {
    includes(:scheme_mix_criteria => [:scheme_mix]).where(scheme_mixes: {certification_path_id: certification_path.id})
  }

  scope :unassigned, -> {
    where(user: nil)
  }

  private
  def assign_default_status
    self.status = :required if self.status.nil?
  end
end
