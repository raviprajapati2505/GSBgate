class SchemeMixCriterion < ActiveRecord::Base
  has_many :scheme_mix_criteria_requirement_data
  has_many :requirement_data, through: :scheme_mix_criteria_requirement_data
  has_many :scheme_mix_criteria_documents
  has_many :documents, through: :scheme_mix_criteria_documents
  has_many :scheme_mix_criterion_logs, dependent: :delete_all
  belongs_to :scheme_mix
  belongs_to :scheme_criterion
  belongs_to :certifier, class_name: 'User', inverse_of: :scheme_mix_criteria

  enum status: [ :in_progress, :complete, :approved, :resubmit ]

  after_initialize :init

  validates :status, inclusion: SchemeMixCriterion.statuses.keys

  validates :targeted_score, presence: true

  scope :reviewed, -> {
    approved | resubmit
  }

  scope :order_by_code, -> {
    joins(:scheme_criterion)
    .reorder('scheme_criteria.code')
  }

  scope :assigned_to_user, ->(user) {
    joins(:requirement_data).where('scheme_mix_criteria.certifier_id = ? or requirement_data.user_id = ?', user.id, user.id)
  }

  scope :for_project, ->(project) {
    joins(:scheme_mix => [:certification_path]).where(certification_paths: {project_id: project.id})
  }

  scope :for_category, ->(category) {
    includes(:scheme_criterion => [:criterion])
    .where(criteria: { category_id: category.id} )
  }

  scope :unassigned, -> {
    where(certifier: nil)
  }

  # returns targeted score taking into account the percentage for which it counts (=weight)
  def weighted_targeted_score
    targeted_score * scheme_criterion.weight / 100 * scheme_mix.weight / 100
  end

  def self::map_to_status_key(status_value)
    value = self.statuses.find { |k,v| v == status_value }
    return value[0].humanize unless value.nil?
  end

  def name
    "#{self.scheme_criterion.code}: #{self.scheme_criterion.criterion.name}"
  end

  def contains_requirement_for?(user)
    requirement_data.each do |requirement_datum|
      if requirement_datum.user == user
        return true
      end
    end
    return false
  end

  private

  def init
    self.status ||= :in_progress
  end
end
