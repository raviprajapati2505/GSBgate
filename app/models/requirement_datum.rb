class RequirementDatum < ActiveRecord::Base
  include Auditable

  has_many :scheme_mix_criteria_requirement_data
  has_many :scheme_mix_criteria, through: :scheme_mix_criteria_requirement_data
  has_many :tasks, dependent: :destroy
  belongs_to :calculator_datum
  belongs_to :requirement
  belongs_to :user

  enum status: { required: 0, provided: 1, not_required: 2 }

  after_initialize :init

  validates :status, inclusion: RequirementDatum.statuses.keys

  default_scope {
    joins(:requirement)
    .order('requirements.name')
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
    includes(:scheme_mix_criteria => [:scheme_criterion]).where(scheme_criteria: {scheme_category_id: category.id})
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

  def name
    requirement.name
  end

  private
  def init
    self.status ||= :required
  end
end
