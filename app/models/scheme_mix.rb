class SchemeMix < ActiveRecord::Base
  belongs_to :certification_path
  belongs_to :scheme
  has_many :scheme_mix_criteria
  has_many :scheme_categories, through: :scheme
  has_many :scheme_criteria, through: :scheme_categories

  after_create :create_descendant_records

  def total_weighted_targeted_score_for_category(category)
    score = scheme_mix_criteria.for_category(category).collect {|sc| sc.weighted_targeted_score}.inject(:+)
    weighted_score(score)
  end

  def total_weighted_submitted_score_for_category(category)
    score = scheme_mix_criteria.for_category(category).collect {|sc| sc.weighted_submitted_score}.inject(:+)
    weighted_score(score)
  end

  def total_weighted_achieved_score_for_category(category)
    score = scheme_mix_criteria.for_category(category).collect {|sc| sc.weighted_achieved_score}.inject(:+)
    weighted_score(score)
  end

  def total_weighted_targeted_score
    score = scheme_mix_criteria.collect {|sc| sc.weighted_targeted_score}.inject(:+)
    weighted_score(score)
  end

  def total_weighted_submitted_score
    score = scheme_mix_criteria.collect {|sc| sc.weighted_submitted_score}.inject(:+)
    weighted_score(score)
  end

  def total_weighted_achieved_score
    score = scheme_mix_criteria.collect {|sc| sc.weighted_achieved_score}.inject(:+)
    weighted_score(score)
  end

  private
    # Class method to calculate the weighted score for this scheme mix
    def weighted_score(score)
      (score * (self.weight / 100))
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
