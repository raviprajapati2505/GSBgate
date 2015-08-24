class SchemeMixCriterion < ActiveRecord::Base
  has_many :scheme_mix_criteria_requirement_data
  has_many :requirement_data, through: :scheme_mix_criteria_requirement_data
  has_many :scheme_mix_criteria_documents
  has_many :documents, through: :scheme_mix_criteria_documents
  has_many :scheme_mix_criterion_logs, dependent: :delete_all
  belongs_to :scheme_mix
  belongs_to :scheme_criterion
  belongs_to :certifier, class_name: 'User', inverse_of: :scheme_mix_criteria
  has_many :user_tasks, dependent: :destroy

  enum status: [ :in_progress, :complete, :approved, :resubmit ]

  after_initialize :init

  validates :status, inclusion: SchemeMixCriterion.statuses.keys

  validates :targeted_score, numericality: { only_integer: true, greater_than_or_equal_to: -1, less_than_or_equal_to: 3 }, presence: true
  validates :submitted_score, numericality: { only_integer: true, greater_than_or_equal_to: -1, less_than_or_equal_to: 3 }, allow_nil: true
  validates :achieved_score, numericality: { only_integer: true, greater_than_or_equal_to: -1, less_than_or_equal_to: 3 }, allow_nil: true

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

  def targeted_score
    calculate_score_combination('targeted_score')
  end

  def submitted_score
    calculate_score_combination('submitted_score')
  end

  def achieved_score
    calculate_score_combination('achieved_score')
  end

  def minimum_attainable_score
    calculate_score_combination('minimum_attainable_score')
  end

  def maximum_attainable_score
    calculate_score_combination('maximum_attainable_score')
  end

  scope :with_all_requirements_completed, -> {
    where.not('exists(select rd.id from requirement_data rd inner join scheme_mix_criteria_requirement_data smcrd on smcrd.requirement_datum_id = rd.id where rd.status = 0 and smcrd.scheme_mix_criterion_id = scheme_mix_criteria.id)')
  }

  # returns targeted score taking into account the percentage for which it counts (=weight)
  def weighted_targeted_score
    (targeted_score * scheme_criterion.weight / 100)
  end

  def weighted_submitted_score
    (submitted_score * scheme_criterion.weight / 100)
  end

  def weighted_achieved_score
    (achieved_score * scheme_criterion.weight / 100)
  end

  def weighted_minimum_attainable_score
    (minimum_attainable_score * scheme_criterion.weight / 100)
  end

  def weighted_maximum_attainable_score
    (maximum_attainable_score * scheme_criterion.weight / 100)
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
    # Class method to calculate the score combination for this scheme criterion
    def calculate_score_combination(score_method)
      if self.scheme_criterion.score_combination_only_a?
        if self.send(score_method + '_a').nil?
          self.scheme_criterion.minimum_attainable_score
        else
          self.send(score_method + '_a')
        end
      elsif self.scheme_criterion.score_combination_average?
        if self.send(score_method + '_a').nil? or self.send(score_method + '_b').nil?
          self.scheme_criterion.minimum_attainable_score
        else
          (self.send(score_method + '_a') + self.send(score_method + '_b')) / 2
        end
      else
        raise 'unknown score combination type: ' + self.scheme_criterion.score_combination_type
      end
    end

    def init
      self.status ||= :in_progress
    end
end
