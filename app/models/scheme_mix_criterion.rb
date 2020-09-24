class SchemeMixCriterion < ApplicationRecord
  include Auditable
  include Taskable
  include ScoreCalculator
  include DatePlucker

  has_many :scheme_mix_criteria_requirement_data, dependent: :destroy
  has_many :requirement_data, through: :scheme_mix_criteria_requirement_data
  has_many :scheme_mix_criteria_documents, dependent: :destroy
  has_many :documents, through: :scheme_mix_criteria_documents
  belongs_to :scheme_mix, optional: true
  belongs_to :scheme_criterion, optional: true
  belongs_to :certifier, class_name: 'User', inverse_of: :scheme_mix_criteria, optional: true
  belongs_to :main_scheme_mix_criterion, class_name: 'SchemeMixCriterion', optional: true
  has_many :archives, as: :subject, dependent: :destroy
  has_many :scheme_mix_criterion_incentives, dependent: :destroy
  has_many :scheme_mix_criterion_epls, dependent: :destroy
  has_many :scheme_mix_criterion_wpls, dependent: :destroy
  has_many :scheme_mix_criterion_boxes, dependent: :destroy

  accepts_nested_attributes_for :scheme_mix_criterion_incentives
  accepts_nested_attributes_for :scheme_mix_criterion_epls
  accepts_nested_attributes_for :scheme_mix_criterion_wpls
  accepts_nested_attributes_for :scheme_mix_criterion_boxes

  enum status: {submitting: 10, submitted: 20, verifying: 30, score_awarded: 41, score_downgraded: 42, score_upgraded: 43, score_minimal:44, appealed: 50, submitting_after_appeal: 60, submitted_after_appeal: 70, verifying_after_appeal: 80, score_awarded_after_appeal: 91, score_downgraded_after_appeal: 92, score_upgraded_after_appeal: 93, score_minimal_after_appeal:94 }

  TARGETED_SCORE_ATTRIBUTES = ['targeted_score_a', 'targeted_score_b'].freeze
  SUBMITTED_SCORE_ATTRIBUTES = ['submitted_score_a', 'submitted_score_b'].freeze
  ACHIEVED_SCORE_ATTRIBUTES = ['achieved_score_a', 'achieved_score_b'].freeze
  INCENTIVE_SCORED_ATTRIBUTES = ['incentive_scored_a', 'incentive_scored_b'].freeze

  after_initialize :init
  after_update :update_inheriting_criteria
  # 'prepend' makes sure that this before_destroy callback will be executed first (before the destroy callbacks on the associations)
  before_destroy :destroy_requirements_documents, prepend: true

  validates :status, inclusion: SchemeMixCriterion.statuses.keys

  validate :validate_score, :validate_incentive_scored

  def validate_score
    return true if self.scheme_mix.certification_path.certificate.construction_certificate?
    if self.scheme_mix.certification_path.certificate.construction_issue_1?
      max_value = 100
      min_value = 0
    else
      max_value = 3
      min_value = -1
    end
    SchemeMixCriterion::TARGETED_SCORE_ATTRIBUTES.each_with_index do |targeted_score, index|
      unless self.scheme_criterion.read_attribute(SchemeCriterion::SCORE_ATTRIBUTES[index].to_sym).nil?
        validates_presence_of targeted_score.to_sym
        validates_numericality_of targeted_score.to_sym, only_integer: false, greater_than_or_equal_to: min_value, less_than_or_equal_to: max_value
      end
    end
    SchemeMixCriterion::SUBMITTED_SCORE_ATTRIBUTES.each_with_index do |submitted_score, index|
      unless self.scheme_criterion.read_attribute(SchemeCriterion::SCORE_ATTRIBUTES[index].to_sym).nil?
        next if self.read_attribute(SchemeMixCriterion::SUBMITTED_SCORE_ATTRIBUTES[index].to_sym).nil?
        validates_numericality_of submitted_score.to_sym, only_integer: false, greater_than_or_equal_to: min_value, less_than_or_equal_to: max_value
      end
    end
    SchemeMixCriterion::ACHIEVED_SCORE_ATTRIBUTES.each_with_index do |achieved_score, index|
      unless self.scheme_criterion.read_attribute(SchemeCriterion::SCORE_ATTRIBUTES[index].to_sym).nil?
        next if self.read_attribute(SchemeMixCriterion::ACHIEVED_SCORE_ATTRIBUTES[index].to_sym).nil?
        validates_numericality_of achieved_score.to_sym, only_integer: false, greater_than_or_equal_to: min_value, less_than_or_equal_to: max_value
      end
    end
  end

  def validate_incentive_scored
    if ['E','W'].include?(self.scheme_criterion.scheme_category.code) && self.scheme_mix.certification_path.certificate.construction_issue_3?
      SchemeCriterion::SCORE_ATTRIBUTES.each_with_index do |scores, index|
        if !self.read_attribute(SchemeMixCriterion::ACHIEVED_SCORE_ATTRIBUTES[index].to_sym).nil? && self.read_attribute(SchemeMixCriterion::ACHIEVED_SCORE_ATTRIBUTES[index].to_sym) <= 0 && self.read_attribute(SchemeMixCriterion::INCENTIVE_SCORED_ATTRIBUTES[index].to_sym) == true
          errors.add(SchemeMixCriterion::INCENTIVE_SCORED_ATTRIBUTES[index].to_sym, 'should be > 0 for Energy and Water categories.')
        end
      end
    end
  end

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

  def targeted_score
    total_targeted_score = 0
    total_weight = self.scheme_criterion.total_weight
    TARGETED_SCORE_ATTRIBUTES.each_with_index do |targeted_score, index|
      unless self.scheme_criterion.read_attribute(SchemeCriterion::SCORE_ATTRIBUTES[index].to_sym).nil?
        total_targeted_score += self.read_attribute(targeted_score.to_sym) * self.scheme_criterion.read_attribute(SchemeCriterion::WEIGHT_ATTRIBUTES[index].to_sym) / total_weight
      end
    end
    return total_targeted_score
  end

  def submitted_score
    total_submitted_score = 0
    total_weight = self.scheme_criterion.total_weight
    SUBMITTED_SCORE_ATTRIBUTES.each_with_index do |submitted_score, index|
      unless self.scheme_criterion.read_attribute(SchemeCriterion::SCORE_ATTRIBUTES[index].to_sym).nil?
        submitted_score_value = self.read_attribute(submitted_score.to_sym)
        submitted_score_value ||= 0
        total_submitted_score += submitted_score_value * self.scheme_criterion.read_attribute(SchemeCriterion::WEIGHT_ATTRIBUTES[index].to_sym) / total_weight
      end
    end
    return total_submitted_score
  end

  def achieved_score
    total_achieved_score = 0
    total_weight = self.scheme_criterion.total_weight
    ACHIEVED_SCORE_ATTRIBUTES.each_with_index do |achieved_score, index|
      unless self.scheme_criterion.read_attribute(SchemeCriterion::SCORE_ATTRIBUTES[index].to_sym).nil?
        achieved_score_value = self.read_attribute(achieved_score.to_sym)
        achieved_score_value ||= 0
        total_achieved_score += achieved_score_value * self.scheme_criterion.read_attribute(SchemeCriterion::WEIGHT_ATTRIBUTES[index].to_sym) / total_weight
      end
    end
    return total_achieved_score
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

      # Check scheme criterion is checklist ?
      if self.scheme_criterion.is_checklist?
        # Check document status
        if has_documents_awaiting_approval?
          todos << 'There are still documents awaiting approval.'
        end
        # Check targeted checklist
        scheme_mix_criterion_boxes.each do |smcb|
          if smcb.scheme_criterion_box.label == "Targeted Checklist Status" && !smcb.is_checked?
            todos << 'The targeted checklist must be checked.'
          elsif smcb.scheme_criterion_box.label == "Submitted Checklist Status" && !smcb.is_checked?
            todos << 'The submitted checklist must be checked.'
          end
        end
        return todos
      end

      # Check requirements statusses
      if has_required_requirements?
        todos << 'The status of all requirements should be set to \'Provided\' or \'Not required\' first.'
      end
      # Check document statusses
      if has_documents_awaiting_approval?
        todos << 'There are still documents awaiting approval.'
      end
      # Check targeted score
      SchemeMixCriterion::TARGETED_SCORE_ATTRIBUTES.each_with_index do |targeted_score, index|
        unless self.scheme_criterion.read_attribute(SchemeCriterion::SCORE_ATTRIBUTES[index].to_sym).nil?
          if self.read_attribute(targeted_score.to_sym).nil?
            todos << 'The targeted level should be set first.'
          end
        end
      end
      # Check submitted score
      SchemeMixCriterion::SUBMITTED_SCORE_ATTRIBUTES.each_with_index do |submitted_score, index|
        unless self.scheme_criterion.read_attribute(SchemeCriterion::SCORE_ATTRIBUTES[index].to_sym).nil?
          if self.read_attribute(submitted_score.to_sym).nil?
            todos << 'The submitted level should be set first.'
          end
        end
      end
    elsif in_verification?
      if self.scheme_criterion.is_checklist?
        # Check achived checklist
        scheme_mix_criterion_boxes.each do |smcb|
          if smcb.scheme_criterion_box.label == "Achieved Checklist Status" && !smcb.is_checked?
            todos << 'The achieved checklist must be checked.' 
          end
        end
        return todos
      end
      # Check submitted score
      SchemeMixCriterion::ACHIEVED_SCORE_ATTRIBUTES.each_with_index do |achieved_score, index|
        unless self.scheme_criterion.read_attribute(SchemeCriterion::SCORE_ATTRIBUTES[index].to_sym).nil?
          if self.read_attribute(achieved_score.to_sym).nil?
            todos << 'The achieved level should be set first.'
          end
        end
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
    total_weight = self.scheme_criterion.total_weight
    used_scores_count = self.scheme_criterion.used_scores_count
    total_achieved_score = 0
    total_submitted_score = 0
    total_minimum_score = 0

    # If there's only an A score, use the absolute scores
    if used_scores_count == 1
      total_achieved_score = self.achieved_score_a
      total_submitted_score = self.submitted_score_a
      total_minimum_score = self.scheme_criterion.minimum_score_a
    # If there are A, B, ... scores, calculate the weighted average scores
    elsif total_weight > 0
      SchemeMixCriterion::ACHIEVED_SCORE_ATTRIBUTES.each_with_index do |achieved_score, index|
        unless self.read_attribute(achieved_score.to_sym).nil?
          total_achieved_score += self.read_attribute(achieved_score.to_sym) * self.scheme_criterion.read_attribute(SchemeCriterion::WEIGHT_ATTRIBUTES[index].to_sym) / total_weight
        end
      end
      SchemeMixCriterion::SUBMITTED_SCORE_ATTRIBUTES.each_with_index do |submitted_score, index|
        unless self.read_attribute(submitted_score.to_sym).nil?
          total_submitted_score += self.read_attribute(submitted_score.to_sym) * self.scheme_criterion.read_attribute(SchemeCriterion::WEIGHT_ATTRIBUTES[index].to_sym) / total_weight
        end
      end
      SchemeCriterion::MIN_SCORE_ATTRIBUTES.each_with_index do |minimal_score, index|
        unless self.scheme_criterion.read_attribute(minimal_score.to_sym).nil?
          total_minimum_score += self.scheme_criterion.read_attribute(minimal_score.to_sym) * self.scheme_criterion.read_attribute(SchemeCriterion::WEIGHT_ATTRIBUTES[index].to_sym) / total_weight
        end
      end
    else
      # TODO: implement a solution for the situation where all weights are zero
    end

    if submitting?
      return :submitted
    elsif submitting_after_appeal?
      return :submitted_after_appeal
    elsif verifying?
      return :score_minimal if total_achieved_score == total_minimum_score
      return :score_awarded if total_achieved_score == total_submitted_score
      return :score_downgraded if total_achieved_score < total_submitted_score
      return :score_upgraded if total_achieved_score > total_submitted_score
      logger.fatal("Error advancing status from verifying for scheme_mix_criterion with ID=#{self.id.to_s}. total_submitted_score=#{total_submitted_score}|total_achieved_score=#{total_achieved_score}|total_minimum_score=#{total_minimum_score}|total_weight=#{total_weight}")
      return false
    elsif verifying_after_appeal?
      return :score_minimal_after_appeal if total_achieved_score == total_minimum_score
      return :score_awarded_after_appeal if total_achieved_score == total_submitted_score
      return :score_downgraded_after_appeal if total_achieved_score < total_submitted_score
      return :score_upgraded_after_appeal if total_achieved_score > total_submitted_score
      logger.fatal("Error advancing status from verifying_after_appeal for scheme_mix_criterion with ID=#{self.id.to_s}. total_submitted_score=#{total_submitted_score}|total_achieved_score=#{total_achieved_score}|total_minimum_score=#{total_minimum_score}|total_weight=#{total_weight}")
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

  # Returns the number of PCR reviews that are still available for this criterion
  def reviews_available
    count = self.scheme_mix.certification_path.max_review_count - self.review_count
    (count < 0) ? 0 : count
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
        (smc_inherit.status = status) if saved_change_to_status?
        SchemeMixCriterion::TARGETED_SCORE_ATTRIBUTES.each do |targeted_score|
          (smc_inherit.send("#{targeted_score}=", self.read_attribute(targeted_score.to_sym))) if self.send("saved_change_to_#{targeted_score}?")
        end
        SchemeMixCriterion::SUBMITTED_SCORE_ATTRIBUTES.each do |submitted_score|
          (smc_inherit.send("#{submitted_score}=", self.read_attribute(submitted_score.to_sym))) if self.send("saved_change_to_#{submitted_score}?")
        end
        SchemeMixCriterion::ACHIEVED_SCORE_ATTRIBUTES.each do |achieved_score|
          (smc_inherit.send("#{achieved_score}=", self.read_attribute(achieved_score.to_sym))) if self.send("saved_change_to_#{achieved_score}?")
        end
        (smc_inherit.screened = screened) if saved_change_to_screened?
        smc_inherit.save!
      end
    end
  end

  def destroy_requirements_documents
    RequirementDatum.joins(:scheme_mix_criteria_requirement_data).where(scheme_mix_criteria_requirement_data: {scheme_mix_criterion_id: id}).destroy_all

    documents.each do |document|
      document.destroy! unless document.scheme_mix_criteria_documents.size > 1
    end
  end


end
