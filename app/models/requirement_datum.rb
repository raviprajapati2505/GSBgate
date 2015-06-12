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
