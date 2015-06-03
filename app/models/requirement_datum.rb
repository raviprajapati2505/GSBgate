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

  scope :for_user_and_project, ->(user, project) {
    includes(:project_authorization).where(project_authorizations: {user_id: user.id, project_id: project.id})
  }

  scope :for_scheme_mix_and_category, ->(scheme_mix, category) {
    includes(:scheme_mix_criteria => [:scheme_criterion => [:criterion]]).where(scheme_mix_criteria: {scheme_mix: scheme_mix}, criteria: {category_id: category.id})
  }

  private
  def assign_default_status
    self.status = :required if self.status.nil?
  end

end
