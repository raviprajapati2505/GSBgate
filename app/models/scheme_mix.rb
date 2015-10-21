class SchemeMix < ActiveRecord::Base
  belongs_to :certification_path
  belongs_to :scheme
  has_many :scheme_mix_criteria
  has_many :scheme_mix_criteria_documents, through: :scheme_mix_criteria
  has_many :scheme_categories, through: :scheme
  has_many :scheme_criteria, through: :scheme_categories

  after_create :create_descendant_records

  def name
    self.scheme.name
  end

  def full_name
    self.scheme.full_name
  end

  def absolute_scores
    {
        :maximum => maximum_score,
        :minimum => minimum_score,
        :targeted => targeted_score,
        :submitted => submitted_score,
        :achieved => achieved_score
    }
  end

  def weighted_scores
    {
        :maximum => maximum_weighted_score,
        :minimum => minimum_weighted_score,
        :targeted => targeted_weighted_score,
        :submitted => submitted_weighted_score,
        :achieved => achieved_weighted_score
    }
  end

  def absolute_scores_for_category(category)
    {
        :maximum => maximum_score_for_category(category),
        :minimum => minimum_score_for_category(category),
        :targeted => targeted_score_for_category(category),
        :submitted => submitted_score_for_category(category),
        :achieved => achieved_score_for_category(category),
    }
  end

  def weighted_scores_for_category(category)
    {
        :maximum => maximum_weighted_score_for_category(category),
        :minimum => minimum_weighted_score_for_category(category),
        :targeted => targeted_weighted_score_for_category(category),
        :submitted => submitted_weighted_score_for_category(category),
        :achieved => achieved_weighted_score_for_category(category),
    }
  end

  def maximum_score
    scheme_mix_criteria.collect { |smc| smc.maximum_weighted_score }.inject(:+)
  end

  def minimum_score
    scheme_mix_criteria.collect { |smc| smc.minimum_weighted_score }.inject(:+)
  end

  def targeted_score
    scheme_mix_criteria.collect { |smc| smc.targeted_weighted_score }.inject(:+)
  end

  def submitted_score
    scheme_mix_criteria.collect { |smc| smc.submitted_weighted_score }.inject(:+)
  end

  def achieved_score
    scheme_mix_criteria.collect { |smc| smc.achieved_weighted_score }.inject(:+)
  end

  def maximum_score_for_category(category)
    scheme_mix_criteria.for_category(category).collect { |smc| smc.maximum_weighted_score }.inject(:+)
  end

  def minimum_score_for_category(category)
    scheme_mix_criteria.for_category(category).collect { |smc| smc.minimum_weighted_score }.inject(:+)
  end

  def targeted_score_for_category(category)
    scheme_mix_criteria.for_category(category).collect { |smc| smc.targeted_weighted_score }.inject(:+)
  end

  def submitted_score_for_category(category)
    scheme_mix_criteria.for_category(category).collect { |smc| smc.submitted_weighted_score }.inject(:+)
  end

  def achieved_score_for_category(category)
    scheme_mix_criteria.for_category(category).collect { |smc| smc.achieved_weighted_score }.inject(:+)
  end

  def maximum_weighted_score
    weighted_score(maximum_score)
  end

  def minimum_weighted_score
    weighted_score(minimum_score)
  end

  def targeted_weighted_score
    weighted_score(targeted_score)
  end

  def submitted_weighted_score
    weighted_score(submitted_score)
  end

  def achieved_weighted_score
    weighted_score(achieved_score)
  end

  def maximum_weighted_score_for_category(category)
    weighted_score(maximum_score_for_category(category))
  end

  def minimum_weighted_score_for_category(category)
    weighted_score(minimum_score_for_category(category))
  end

  def targeted_weighted_score_for_category(category)
    weighted_score(targeted_score_for_category(category))
  end

  def submitted_weighted_score_for_category(category)
    weighted_score(submitted_score_for_category(category))
  end

  def achieved_weighted_score_for_category(category)
    weighted_score(achieved_score_for_category(category))
  end

  private

  # Class method to calculate the weighted score for this scheme mix
  def weighted_score(score)
    (score.to_f * (weight.to_f / 100.to_f))
  end

  # Mirrors all the descendant structural data records of the SchemeMix to user data records
  def create_descendant_records
    # Loop all the criteria of the scheme
    scheme.scheme_criteria.each do |scheme_criterion|
      # Create a SchemeMixCriterion for every criterion
      scheme_mix_criterion = SchemeMixCriterion.create!(targeted_score: scheme_criterion.scores.max, scheme_mix: self, scheme_criterion: scheme_criterion)

      # Loop all requirements of the criterion
      scheme_criterion.requirements.each do |requirement|
        # Check whether the RequirementDatum record already exists (a Requirement can be linked to multiple scheme criteria)
        requirement_datum = RequirementDatum
                                .joins(:scheme_mix_criteria_requirement_data)
                                .joins(:scheme_mix_criteria)
                                .where(requirement: requirement)
                                .where(scheme_mix_criteria: {scheme_mix_id: self}).first

        # If RequirementDatum doesn't exist
        if requirement_datum.nil?
          # If the Requirement has a Calculator
          if requirement.calculator.present?
            # Create a CalculatorDatum
            calculator_datum = CalculatorDatum.create!(calculator_id: requirement.calculator_id)

            # Create a RequirementDatum
            scheme_mix_criterion.requirement_data.create!(calculator_datum_id: calculator_datum.id, requirement_id: requirement.id)

            # Loop all fields of the calculator
            requirement.calculator.fields.each do |field|
              # Create a FieldDatum for each field
              calculator_datum.field_data.create!(field_id: field.id, type: field.datum_type)
            end
            # If the Requirement doesn't have a Calculator
          else
            # Create a RequirementDatum
            scheme_mix_criterion.requirement_data.create!(requirement_id: requirement.id)
          end
          # If RequirementDatum exists
        else
          # Link the SchemeMixCriterium to the existing RequirementDatum
          scheme_mix_criterion.scheme_mix_criteria_requirement_data.create!(requirement_datum_id: requirement_datum.id)
        end
      end
    end
  end
end
