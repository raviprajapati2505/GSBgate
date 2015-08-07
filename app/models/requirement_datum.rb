class RequirementDatum < ActiveRecord::Base
  has_many :scheme_mix_criteria_requirement_data
  has_many :scheme_mix_criteria, through: :scheme_mix_criteria_requirement_data
  belongs_to :calculator_datum
  belongs_to :requirement
  belongs_to :user

  enum status: [ :required, :provided, :not_required ]

  before_validation :assign_default_status, on: :create

  validates :status, inclusion: RequirementDatum.statuses.keys

  # validate :validate_fields

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

  scope :targeted, -> {
    # includes(:scheme_mix_criteria).where.not(scheme_mix_criteria: {targeted_score: -1, status: 1})
    includes(:scheme_mix_criteria).where.not('scheme_mix_criteria.targeted_score = -1 and scheme_mix_criteria.status = 1')
  }

  private
  def assign_default_status
    self.status = :required if self.status.nil?
  end

  # def validate_fields
  #   calculator_datum.field_data.each do |field_datum|
  #     if field_datum.invalid?
  #       # errors.add("field-datum-#{field_datum.id}", field_datum.errors.messages.values)
  #       errors.add("field-datum-#{field_datum.id}", field_datum.errors.first[1])
  #     end
  #   end
  # end

end
