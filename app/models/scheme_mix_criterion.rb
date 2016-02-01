class SchemeMixCriterion < ActiveRecord::Base
  include Auditable
  include Taskable
  include ScoreCalculator

  has_many :scheme_mix_criteria_requirement_data, dependent: :destroy
  has_many :requirement_data, through: :scheme_mix_criteria_requirement_data
  has_many :scheme_mix_criteria_documents, dependent: :destroy
  has_many :documents, through: :scheme_mix_criteria_documents
  belongs_to :scheme_mix
  belongs_to :scheme_criterion
  belongs_to :certifier, class_name: 'User', inverse_of: :scheme_mix_criteria
  belongs_to :main_scheme_mix_criterion, class_name: 'SchemeMixCriterion'

  enum status: {submitting: 0, submitted: 1, verifying: 2, submitted_score_achieved: 3, submitted_score_not_achieved: 4, appealed: 5, submitting_after_appeal: 6, submitted_after_appeal: 7, verifying_after_appeal: 8, submitted_score_achieved_after_appeal: 9, submitted_score_not_achieved_after_appeal: 10}

  after_initialize :init

  validates :status, inclusion: SchemeMixCriterion.statuses.keys

  validates :targeted_score, numericality: {only_integer: true, greater_than_or_equal_to: -1, less_than_or_equal_to: 3}, presence: true
  validates :submitted_score, numericality: {only_integer: true, greater_than_or_equal_to: -1, less_than_or_equal_to: 3}, allow_nil: true
  validates :achieved_score, numericality: {only_integer: true, greater_than_or_equal_to: -1, less_than_or_equal_to: 3}, allow_nil: true

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

  scope :in_submission, -> {
    where(status: [SchemeMixCriterion.statuses[:submitting], SchemeMixCriterion.statuses[:submitting_after_appeal]])
  }

  scope :in_verification, -> {
    where(status: [SchemeMixCriterion.statuses[:verifying], SchemeMixCriterion.statuses[:verifying_after_appeal]])
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
    return verifying? || submitted_score_achieved? || submitted_score_not_achieved? || verifying_after_appeal? || submitted_score_achieved_after_appeal? || submitted_score_not_achieved_after_appeal?
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

  private

  def init
    if self.has_attribute?('status')
      self.status ||= :submitting
    end
  end

end
