class RequirementDatum < ApplicationRecord
  include Auditable
  include Taskable

  has_many :scheme_mix_criteria_requirement_data, dependent: :destroy
  has_many :scheme_mix_criteria, through: :scheme_mix_criteria_requirement_data
  belongs_to :calculator_datum, dependent: :destroy, optional: true
  belongs_to :requirement, optional: true
  belongs_to :user, optional: true

  enum status: { required: 3, provided: 1, unneeded: 2 }

  after_initialize :init
  after_update :submit_scheme_mix_criterion_if_unneeded

  validates :status, inclusion: RequirementDatum.statuses.keys

  default_scope {
    joins(:requirement)
    .order('requirements.display_weight')
  }

  scope :completed, -> {
    provided | unneeded
  }

  scope :assigned_to_user, ->(user) {
    where(user: user)
  }

  scope :not_assigned_to_user, ->(user) {
    where('(requirement_data.user_id <> %d) OR (requirement_data.user_id IS NULL)', user.id)
  }

  scope :for_project, ->(project) {
    includes(:scheme_mix_criteria => [:scheme_mix => [:certification_path]]).where(certification_paths: {project_id: project.id})
  }

  scope :for_category, ->(category) {
    includes(:scheme_mix_criteria => [:scheme_criterion]).where(scheme_criteria: {scheme_category_id: category.id})
  }

  scope :for_scheme_mix, ->(scheme_mix) {
    includes(:scheme_mix_criteria).where(scheme_mix_criteria: {scheme_mix: scheme_mix})
  }

  scope :for_certification_path, ->(certification_path) {
    includes(:scheme_mix_criteria => [:scheme_mix]).where(scheme_mixes: {certification_path_id: certification_path.id})
  }

  scope :unassigned, -> {
    where(user: nil)
  }

  def name
    requirement.name
  end

  private
  def init
    self.status ||= :required
  end

  # Set targeted & submitted scores of the parent SchemeMixCriterion to the minimum valid score & submit it,
  # if all requirement datum records are flagged as "not required"
  def submit_scheme_mix_criterion_if_unneeded
    self.transaction do
      # Loop all requirement data records of the scheme mix criterion parent
      scheme_mix_criteria.each do |smc|
        if smc.in_submission?
          all_unneeded = true
          smc.requirement_data.each do |requirement_datum|
            unless requirement_datum.unneeded?
              all_unneeded = false
              break
            end
          end

          # If all requirement datum records are flagged as "not required",
          # set targeted & submitted scores to the minimum valid score & submit the criterion
          if all_unneeded
            SchemeCriterion::MIN_VALID_SCORE_ATTRIBUTES.each_with_index do |min_valid_score, index|
              unless smc.scheme_criterion.read_attribute(SchemeCriterion::SCORE_ATTRIBUTES[index].to_sym).nil?
                min_valid_score = smc.scheme_criterion.read_attribute(min_valid_score.to_sym)
                smc.send("#{SchemeMixCriterion::TARGETED_SCORE_ATTRIBUTES[index]}=", min_valid_score)
                smc.send("#{SchemeMixCriterion::SUBMITTED_SCORE_ATTRIBUTES[index]}=", min_valid_score)
              end
            end
            smc.status = smc.next_status
            smc.save!
          end
        end
      end
    end
  end
end
