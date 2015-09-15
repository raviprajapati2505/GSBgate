class SchemeMixCriterion < AuditableRecord
  has_many :scheme_mix_criteria_requirement_data
  has_many :requirement_data, through: :scheme_mix_criteria_requirement_data
  has_many :scheme_mix_criteria_documents
  has_many :documents, through: :scheme_mix_criteria_documents
  belongs_to :scheme_mix
  belongs_to :scheme_criterion
  belongs_to :certifier, class_name: 'User', inverse_of: :scheme_mix_criteria

  enum status: { in_progress: 0, complete: 1 , approved: 2, resubmit: 3 }

  after_initialize :init

  validates :status, inclusion: SchemeMixCriterion.statuses.keys

  validates :targeted_score, numericality: { only_integer: true, greater_than_or_equal_to: -1, less_than_or_equal_to: 3 }, presence: true
  validates :submitted_score, numericality: { only_integer: true, greater_than_or_equal_to: -1, less_than_or_equal_to: 3 }, allow_nil: true
  validates :achieved_score, numericality: { only_integer: true, greater_than_or_equal_to: -1, less_than_or_equal_to: 3 }, allow_nil: true

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

   def targeted_score_safe
    if targeted_score.nil?
      scheme_criterion.minimum_attainable_score
    else
      targeted_score
    end
  end

  def submitted_score_safe
    if submitted_score.nil?
      scheme_criterion.minimum_attainable_score
    else
      submitted_score
    end
  end

  def achieved_score_safe
    if achieved_score.nil?
      scheme_criterion.minimum_attainable_score
    else
      achieved_score
    end
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

  # returns targeted score taking into account the percentage for which it counts (=weight)
  def weighted_targeted_score
    scheme_criterion.weighted_score(targeted_score_safe)
  end

  def weighted_submitted_score
    scheme_criterion.weighted_score(submitted_score_safe)
  end

  def weighted_achieved_score
    scheme_criterion.weighted_score(achieved_score_safe)
  end

  def self::map_to_status_key(status_value)
    value = self.statuses.find { |k,v| v == status_value }
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

  private
    def init
      self.status ||= :in_progress
    end
end
