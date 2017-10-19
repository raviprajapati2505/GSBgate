class SchemeMixCriterion < ActiveRecord::Base
  include Auditable
  include Taskable
  include ScoreCalculator
  include DatePlucker

  has_many :scheme_mix_criteria_requirement_data, dependent: :destroy
  has_many :requirement_data, through: :scheme_mix_criteria_requirement_data
  has_many :scheme_mix_criteria_documents, dependent: :destroy
  has_many :documents, through: :scheme_mix_criteria_documents
  belongs_to :scheme_mix
  belongs_to :scheme_criterion
  belongs_to :certifier, class_name: 'User', inverse_of: :scheme_mix_criteria
  belongs_to :main_scheme_mix_criterion, class_name: 'SchemeMixCriterion'

  enum status: {submitting: 10, submitted: 20, verifying: 30, score_awarded: 41, score_downgraded: 42, score_upgraded: 43, score_minimal:44, appealed: 50, submitting_after_appeal: 60, submitted_after_appeal: 70, verifying_after_appeal: 80, score_awarded_after_appeal: 91, score_downgraded_after_appeal: 92, score_upgraded_after_appeal: 93, score_minimal_after_appeal:94 }

  after_initialize :init
  after_update :update_inheriting_criteria

  validates :status, inclusion: SchemeMixCriterion.statuses.keys

  validates :targeted_score, numericality: {only_integer: false, greater_than_or_equal_to: -1, less_than_or_equal_to: 3}, presence: true, unless: 'scheme_mix.certification_path.certificate.construction_issue_1?'
  validates :targeted_score, numericality: {only_integer: false, greater_than_or_equal_to: 0, less_than_or_equal_to: 100}, presence: true, if: 'scheme_mix.certification_path.certificate.construction_issue_1?'
  validates :submitted_score, numericality: {only_integer: false, greater_than_or_equal_to: -1, less_than_or_equal_to: 3}, allow_nil: true, unless: 'scheme_mix.certification_path.certificate.construction_issue_1?'
  validates :submitted_score, numericality: {only_integer: false, greater_than_or_equal_to: 0, less_than_or_equal_to: 100}, allow_nil: true, if: 'scheme_mix.certification_path.certificate.construction_issue_1?'
  validates :achieved_score, numericality: {only_integer: false, greater_than_or_equal_to: -1, less_than_or_equal_to: 3}, allow_nil: true, unless: 'scheme_mix.certification_path.certificate.construction_issue_1?'
  validates :achieved_score, numericality: {only_integer: false, greater_than_or_equal_to: 0, less_than_or_equal_to: 100}, allow_nil: true, if: 'scheme_mix.certification_path.certificate.construction_issue_1?'

  scope :assigned_to_user, ->(user) {
    joins(:requirement_data).where('scheme_mix_criteria.certifier_id = ? or requirement_data.user_id = ?', user.id, user.id)
  }

  scope :assigned_to_certifier, ->(certifier) {
    where(certifier_id: certifier.id)
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

  scope :in_submission, -> {
    where(status: [SchemeMixCriterion.statuses[:submitting], SchemeMixCriterion.statuses[:submitting_after_appeal]])
  }

  scope :in_verification, -> {
    where(status: [SchemeMixCriterion.statuses[:verifying], SchemeMixCriterion.statuses[:verifying_after_appeal]])
  }

  scope :unscreened, -> {
    where(screened: false)
  }

  def name
    self.scheme_criterion.name
  end

  def full_name
    self.scheme_criterion.full_name
  end

  def code
    self.scheme_criterion.code
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

    if in_submission?
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
    elsif in_verification?
      # Check submitted score
      if achieved_score.nil?
        todos << 'The achieved score should be set first.'
      end
    end

    return todos
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

   def in_submission?
    if self.submitting? || self.submitting_after_appeal?
      return true
    end
    return false
  end

  def in_verification?
    if self.verifying? || self.verifying_after_appeal?
      return true
    end
    return false
  end

  def at_certifier_side?
    return verifying? || score_minimal? || score_awarded? || score_downgraded? || score_upgraded? || verifying_after_appeal? || score_minimal_after_appeal? || score_awarded_after_appeal? || score_downgraded_after_appeal? || score_upgraded_after_appeal?
  end

  # This overrides default behaviour
  # by default the 'id' is always an integer, but sometimes you want to use a string
  # if an attribute 'id_text' exists then use the value for the 'id' attribute after explicit conversion to string
  def as_json(options)
    attrs = super(options)
    if attrs['id_text'].present?
      attrs['id'] = attrs['id_text'].to_s
      attrs.delete('id_text')
    end
    attrs
  end

  # Returns the next SchemeMixCriterion model in the SchemeMix
  # or nil if there is no next model
  def next_scheme_mix_criterion
    self.class.includes(:scheme_mix, scheme_criterion: [:scheme_category])
              .where('scheme_mixes.id = ? AND ((scheme_categories.id = ? AND scheme_criteria.number > ?) OR (scheme_categories.display_weight > ?))', self.scheme_mix_id, self.scheme_criterion.scheme_category.id, self.scheme_criterion.number, self.scheme_criterion.scheme_category.display_weight)
              .order('scheme_categories.display_weight, scheme_criteria.number')
              .first
  end

  # Returns the previous SchemeMixCriterion model in the SchemeMix
  # or nil if there is no previous model
  def previous_scheme_mix_criterion
    self.class.includes(:scheme_mix, scheme_criterion: [:scheme_category])
              .where('scheme_mixes.id = ? AND ((scheme_categories.id = ? AND scheme_criteria.number < ?) OR (scheme_categories.display_weight < ?))', self.scheme_mix_id, self.scheme_criterion.scheme_category.id, self.scheme_criterion.number, self.scheme_criterion.scheme_category.display_weight)
              .order('scheme_categories.display_weight, scheme_criteria.number')
              .last
  end

  def next_status
    if submitting?
      return :submitted
    elsif submitting_after_appeal?
      return :submitted_after_appeal
    elsif verifying?
      return :score_minimal if achieved_score == scheme_criterion.minimum_score
      return :score_awarded if achieved_score == submitted_score
      return :score_downgraded if achieved_score < submitted_score
      return :score_upgraded if achieved_score > submitted_score
      logger.fatal('Error advancing status from verifying')
      return false
    elsif verifying_after_appeal?
      return :score_minimal_after_appeal if achieved_score == scheme_criterion.minimum_score
      return :score_awarded_after_appeal if achieved_score == submitted_score
      return :score_downgraded_after_appeal if achieved_score < submitted_score
      return :score_upgraded_after_appeal if achieved_score > submitted_score
      logger.fatal('Error advancing status from verifying_after_appeal')
      return false
    elsif submitted? && [CertificationPathStatus::SUBMITTING, CertificationPathStatus::SUBMITTING_AFTER_SCREENING].include?(scheme_mix.certification_path.certification_path_status_id)
      return :submitting
    elsif submitted_after_appeal? && (scheme_mix.certification_path.certification_path_status_id == CertificationPathStatus::SUBMITTING_AFTER_APPEAL)
      return :submitting_after_appeal
    elsif (score_minimal? || score_awarded? || score_downgraded? || score_upgraded?) && (scheme_mix.certification_path.certification_path_status_id == CertificationPathStatus::VERIFYING)
      return :verifying
    elsif (score_minimal_after_appeal? || score_awarded_after_appeal? || score_downgraded_after_appeal? || score_upgraded_after_appeal?) && (scheme_mix.certification_path.certification_path_status_id == CertificationPathStatus::VERIFYING_AFTER_APPEAL)
      return :verifying_after_appeal
    else
      return false
    end
  end

  def visible_status
    # hide real criterion status in some cases
    certification_path = self.scheme_mix.certification_path
    project = certification_path.project
    if User.current.default_role? && (project.role_for_user(User.current) != ProjectsUser.roles.keys[ProjectsUser.roles[:certifier]] && project.role_for_user(User.current) != ProjectsUser.roles.keys[ProjectsUser.roles[:certification_manager]])
      if certification_path.certification_path_status_id == CertificationPathStatus::VERIFYING
        self.status = SchemeMixCriterion::statuses[:verifying]
      elsif certification_path.certification_path_status_id == CertificationPathStatus::VERIFYING_AFTER_APPEAL && SchemeMixCriterion::statuses[self.status] >= SchemeMixCriterion::statuses[:verifying_after_appeal]
        self.status = SchemeMixCriterion::statuses[:verifying_after_appeal]
      end
    end
    return self
  end

  private

  def init
    if self.has_attribute?('status')
      self.status ||= :submitting
    end
  end

  # Updates SchemeMixCriterion models that inherit from this model
  def update_inheriting_criteria
    scheme_mix = self.scheme_mix
    certification_path = self.scheme_mix.certification_path

    # If the criterion is in a shared category of the main scheme mix,
    # also update scheme mix criteria that inherit from this one
    if (certification_path.main_scheme_mix_id == scheme_mix.id) && scheme_criterion.scheme_category.shared?
      certification_path.scheme_mix_criteria.where(main_scheme_mix_criterion_id: id).each do |smc_inherit|
        (smc_inherit.status = status) if status_changed?
        (smc_inherit.targeted_score = targeted_score) if targeted_score_changed?
        (smc_inherit.submitted_score = submitted_score) if submitted_score_changed?
        (smc_inherit.achieved_score = achieved_score) if achieved_score_changed?
        (smc_inherit.screened = screened) if screened_changed?
        smc_inherit.save!
      end
    end
  end

end
