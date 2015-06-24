class SchemeMixCriterion < ActiveRecord::Base
  has_many :scheme_mix_criteria_requirement_data
  has_many :requirement_data, through: :scheme_mix_criteria_requirement_data
  has_many :scheme_mix_criteria_documents
  has_many :documents, through: :scheme_mix_criteria_documents
  has_many :criteria_status_logs, dependent: :delete_all
  belongs_to :scheme_mix
  belongs_to :scheme_criterion
  belongs_to :certifier, class_name: 'User'

  enum status: [ :in_progress, :complete ]

  before_validation :assign_default_status, on: :create

  validates :status, inclusion: SchemeMixCriterion.statuses.keys

  validates :targeted_score, presence: true

  scope :order_by_code, -> {
    joins(:scheme_criterion)
    .reorder('scheme_criteria.code')
  }
  scope :assigned_to_user, ->(user) {
    joins(:requirement_data)
        .where(requirement_data: {user_id: user.id})
  }

  scope :for_project, ->(project) {
    joins(:scheme_mix => [:certification_path]).where(certification_paths: {project_id: project.id})
  }

  scope :for_category, ->(category) {
    includes(:scheme_criterion => [:criterion])
    .where(criteria: { category_id: category.id} )
  }

  default_scope {
    joins(:scheme_criterion => [:criterion])
    .order('criteria.name')
  }

  # returns targeted score taking into account the percentage for which it counts (=weight)
  def weighted_targeted_score
    targeted_score * scheme_criterion.weight / 100 * scheme_mix.weight / 100
  end

  def self::map_to_status_key(status_value)
    value = self.statuses.find { |k,v| v == status_value }
    return value[0].humanize unless value.nil?
  end

  private
  def assign_default_status
    self.status = :in_progress if self.status.nil?
  end
end
