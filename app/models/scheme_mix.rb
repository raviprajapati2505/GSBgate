class SchemeMix < ApplicationRecord
  include ScoreCalculator

  belongs_to :certification_path, optional: true
  belongs_to :scheme, optional: true
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
    # "GSB #{Certificate.human_attribute_name(self.certification_path.certificate.assessment_stage)} Assessment v#{self.scheme.gsb_version}: #{self.name}"
    name
  end

  def check_list?
    self.certification_path.is_checklist_method?
  end

  def gross_area
    project = certification_path.project
    total_gross_area = project.gross_area
    scheme_mix_gross_area = (total_gross_area * weight) / 100 rescue 0.0
    return scheme_mix_gross_area
  end

  def certified_area
    project = certification_path.project
    total_certified_area = project.certified_area
    scheme_mix_certified_area = (total_certified_area * weight) / 100 rescue 0.0
    return scheme_mix_certified_area
  end

  # Mirrors all the descendant structural data records of the SchemeMix to user data records
  def create_descendant_records
    # Build a list of all criteria codes/ids of the main scheme mix
    main_scheme_mix_criteria = {}
    if certification_path.main_scheme_mix.present?
      certification_path.main_scheme_mix.scheme.scheme_categories.each do |main_scheme_category|
        main_scheme_category.scheme_criteria.each do |main_scheme_criterion|
          if main_scheme_criterion.shared? 
            main_scheme_mix_criteria[main_scheme_criterion.code] = main_scheme_criterion.id
          end
        end
      end
    end

    scheme_of_criteria = if self.check_list?
      scheme.scheme_criteria.where(is_checklist: true)
    else
      scheme.scheme_criteria.where(is_checklist: false)
    end

    # Loop all the criteria of the scheme
    scheme_of_criteria.each do |scheme_criterion|
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
      parameter_list = {scheme_mix: self, scheme_criterion: scheme_criterion, main_scheme_mix_criterion_id: main_scheme_mix_criterion_id}
      SchemeCriterion::MAX_SCORE_ATTRIBUTES.each_with_index do |max_score, index|
        parameter_list[SchemeMixCriterion::TARGETED_SCORE_ATTRIBUTES[index].to_sym] = scheme_criterion.read_attribute(max_score.to_sym)
        parameter_list[SchemeMixCriterion::INCENTIVE_SCORED_ATTRIBUTES[index].to_sym] = scheme_criterion.read_attribute(SchemeCriterion::CALCULATE_INCENTIVE_ATTRIBUTES[index].to_sym)
      end

      scheme_mix_criterion = SchemeMixCriterion.create!(parameter_list)
      if self.check_list?
        scheme_criterion.scheme_criterion_box_ids.each do |box_id|
          scheme_mix_criterion.scheme_mix_criterion_boxes.create!(scheme_criterion_box_id: box_id, is_checked: false)
        end
      end

      # Create all SchemeMixCriterionIncentive records
      scheme_criterion.scheme_criterion_incentive_ids.each do |incentive_id|
        scheme_mix_criterion.scheme_mix_criterion_incentives.create!(scheme_criterion_incentive_id: incentive_id, incentive_scored: false)
      end

      # Create all SchemeMixCriterionEpls and SchemeMixCriterionWpls
      scheme_criterion.scheme_criterion_epl_ids.each do |epl_id|
        scheme_mix_criterion.scheme_mix_criterion_epls.create!(scheme_criterion_performance_labels_id: epl_id)
      end
      scheme_criterion.scheme_criterion_wpl_ids.each do |wpl_id|
        scheme_mix_criterion.scheme_mix_criterion_wpls.create!(scheme_criterion_performance_labels_id: wpl_id)
      end

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

  def category_scheme_mix_criteria(scheme_category_id)
    self.scheme_mix_criteria.joins(:scheme_criterion).where("scheme_criteria.scheme_category_id = :scheme_category_id", scheme_category_id: scheme_category_id)
  end

end
