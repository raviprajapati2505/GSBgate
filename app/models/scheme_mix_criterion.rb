class SchemeMixCriterion < ActiveRecord::Base
  include Auditable
  include Taskable

  has_many :scheme_mix_criteria_requirement_data
  has_many :requirement_data, through: :scheme_mix_criteria_requirement_data
  has_many :scheme_mix_criteria_documents
  has_many :documents, through: :scheme_mix_criteria_documents
  has_many :tasks, dependent: :destroy
  belongs_to :scheme_mix
  belongs_to :scheme_criterion
  belongs_to :certifier, class_name: 'User', inverse_of: :scheme_mix_criteria

  enum status: {submitting: 0, submitted: 1, verifying: 2, target_achieved: 3, target_not_achieved: 4, appealed: 5, submitting_after_appeal: 6, submitted_after_appeal: 7, verifying_after_appeal: 8, target_achieved_after_appeal: 9, target_not_achieved_after_appeal: 10}

  after_initialize :init

  validates :status, inclusion: SchemeMixCriterion.statuses.keys

  validates :targeted_score, numericality: {only_integer: true, greater_than_or_equal_to: -1, less_than_or_equal_to: 3}, presence: true
  validates :submitted_score, numericality: {only_integer: true, greater_than_or_equal_to: -1, less_than_or_equal_to: 3}, allow_nil: true
  validates :achieved_score, numericality: {only_integer: true, greater_than_or_equal_to: -1, less_than_or_equal_to: 3}, allow_nil: true

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
    # includes(:scheme_criterion => [:criterion])
    # .where(criteria: { category_id: category.id} )
    joins(:scheme_criterion)
        .where(scheme_criteria: {scheme_category_id: category.id})
  }

  scope :unassigned, -> {
    where(certifier: nil)
  }

  def name
    self.scheme_criterion.name
  end

  def full_name
    self.scheme_criterion.full_name
  end

  def has_required_requirements?
    requirement_data.each do |requirement|
      if requirement.required?
        return true
      end
    end
    return false
  end

  def has_documents_awaiting_approval?
    scheme_mix_criteria_documents.each do |document|
      if document.awaiting_approval?
        return true
      end
    end
    return false
  end

  def todo_before_status_advance
    todos = []

    if submitting? or submitting_after_appeal?
      # Check requirements statusses
      if has_required_requirements?
        todos << 'The status of all requirements should be set to \'Provided\' or \'Not required\' first.'
      end
      # Check document statusses
      if has_documents_awaiting_approval?
        todos << 'There are still documents awaiting approval.'
      end
      # Check targeted score
      if targeted_score.nil?
        todos << 'The targeted score should be set first.'
      end
      # Check submitted score
      if submitted_score.nil?
        todos << 'The submitted score should be set first.'
      end
    elsif verifying? or verifying_after_appeal?
      # Check submitted score
      if achieved_score.nil?
        todos << 'The achieved score should be set first.'
      end
    end

    return todos
  end

  # returns scores taking into account the percentage for which it counts (=weight)
  def score_types
    return [:absolute, :weighted]
  end

  def self::map_to_status_key(status_value)
    value = self.statuses.find { |k, v| v == status_value }
    return value[0].humanize unless value.nil?
  end

  def contains_requirement_for?(user)
    requirement_data.each do |requirement_datum|
      if requirement_datum.user == user
        return true
      end
    end
    return false
  end

  def scores_in_certificate_points
    {
        :maximum => convert_to_certificate_points(maximum_score),
        :minimum =>  convert_to_certificate_points(minimum_score),
        :targeted => convert_to_certificate_points(targeted_score_safe),
        :submitted => convert_to_certificate_points(submitted_score_safe),
        :achieved => convert_to_certificate_points(achieved_score_safe)
    }
  end

  def scores_in_scheme_points
    {
        :maximum => convert_to_scheme_points(maximum_score),
        :minimum =>  convert_to_scheme_points(minimum_score),
        :targeted => convert_to_scheme_points(targeted_score_safe),
        :submitted => convert_to_scheme_points(submitted_score_safe),
        :achieved => convert_to_scheme_points(achieved_score_safe)
    }
  end

  def scores
    {
        :maximum => maximum_score,
        :minimum =>  minimum_score,
        :targeted => targeted_score_safe,
        :submitted => submitted_score_safe,
        :achieved => achieved_score_safe
    }
  end

  def targeted_score_safe
    if targeted_score.nil?
      scheme_criterion.minimum_score
    else
      targeted_score
    end
  end

  def submitted_score_safe
    if submitted_score.nil?
      scheme_criterion.minimum_score
    else
      submitted_score
    end
  end

  def achieved_score_safe
    if achieved_score.nil?
      scheme_criterion.minimum_score
    else
      achieved_score
    end
  end

  def maximum_score
    scheme_criterion.maximum_score
  end

  def minimum_score
    scheme_criterion.minimum_score
  end

  # these are actual fields
  #   targeted_score
  #   submitted_score
  #   achieved_score

  def convert_to_certificate_points(score)
    score = convert_to_scheme_points(score)
    (score.to_f * (scheme_mix.weight.to_f / 100.to_f))
  end

  def convert_to_scheme_points(score)
    # returns weighted score, taking into account the percentage for which it counts (=weight)
    #NOTE: we multiply the weight with 3, as we need a final score on a scale based on a total of 3, not 1
    (score.to_f  / scheme_criterion.maximum_score.to_f ) * ((3.to_f  * scheme_criterion.weight.to_f ) / 100.to_f)
  end

  private

  def init
    self.status ||= :submitting
  end

end
