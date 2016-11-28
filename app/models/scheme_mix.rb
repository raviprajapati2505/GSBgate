class SchemeMix < ActiveRecord::Base
  include ScoreCalculator

  belongs_to :certification_path
  belongs_to :scheme
  has_many :scheme_mix_criteria, dependent: :destroy
  has_many :scheme_mix_criteria_documents, through: :scheme_mix_criteria
  has_many :scheme_categories, through: :scheme
  has_many :scheme_criteria, through: :scheme_categories
  has_many :certification_paths, class_name: "CertificationPath", foreign_key: "main_scheme_mix_id", dependent: :nullify

  validates :weight, numericality: { greater_than: 0 }

  def name
    if custom_name.present?
      "#{self.scheme.name} (#{custom_name})"
    else
      "#{self.scheme.name}"
    end
  end

  def full_name
      "GSAS #{Certificate.human_attribute_name(self.certification_path.certificate.assessment_stage)} Assessment v#{self.scheme.gsas_version}: #{self.name}"
  end

  # Mirrors all the descendant structural data records of the SchemeMix to user data records
  def create_descendant_records
    # Build a list of all criteria codes/ids of the main scheme mix
    main_scheme_mix_criteria = {}
    if certification_path.main_scheme_mix.present?
      certification_path.main_scheme_mix.scheme.scheme_categories.each do |main_scheme_category|
        main_scheme_category.scheme_criteria.each do |main_scheme_criterion|
          main_scheme_mix_criteria[main_scheme_criterion.code] = main_scheme_criterion.id
        end
      end
    end

    # Loop all the criteria of the scheme
    scheme.scheme_criteria.each do |scheme_criterion|
      # Check whether the new scheme mix criterion will have a main scheme mix criterion
      has_main_scheme_mix_criterion = (certification_path.development_type.mixable? && certification_path.main_scheme_mix.present? && scheme_criterion.scheme_category.shared? && (id != certification_path.main_scheme_mix_id) && main_scheme_mix_criteria.has_key?(scheme_criterion.code))

      # If there is a main scheme mix criterion, get the id
      main_scheme_mix_criterion_id = nil
      if has_main_scheme_mix_criterion
        # Find the id of the main scheme criterion by code
        main_scheme_criterion_id = main_scheme_mix_criteria[scheme_criterion.code]

        # Load the SchemeMixCriterion by scheme id & scheme criterion id
        main_scheme_mix_criterion = SchemeMixCriterion.select(:id).find_by(scheme_mix_id: certification_path.main_scheme_mix_id, scheme_criterion_id: main_scheme_criterion_id)

        # Set the main scheme criterion id
        if main_scheme_mix_criterion.present?
          main_scheme_mix_criterion_id = main_scheme_mix_criterion.id
        end
      end

      # Create a SchemeMixCriterion record
      scheme_mix_criterion = SchemeMixCriterion.create!(targeted_score: scheme_criterion.maximum_score, scheme_mix: self, scheme_criterion: scheme_criterion, main_scheme_mix_criterion_id: main_scheme_mix_criterion_id)

      # Don't create requirement data records for criteria that inherit their scores from the main scheme mix
      unless has_main_scheme_mix_criterion
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

end
