class SchemeMix < ActiveRecord::Base
  belongs_to :certification_path
  belongs_to :scheme
  has_many :scheme_mix_criteria
  has_many :scheme_criteria, through: :scheme
  has_many :criteria, through: :scheme_criteria
  has_many :categories, through: :criteria

  after_create :create_descendant_records

  def weighted_min_score
    weighted_max_attainable_score = 0
    scheme_mix_criteria.each do |scheme_mix_criteria|
      weighted_max_attainable_score += scheme_mix_criteria.scheme_criterion.scores.to_a.min_by(&:score).score * scheme_mix_criteria.scheme_criterion.weight / 100 * weight / 100
    end
    return weighted_max_attainable_score
  end

  def weighted_max_attainable_score
    weighted_max_attainable_score = 0
    scheme_mix_criteria.each do |scheme_mix_criteria|
      weighted_max_attainable_score += scheme_mix_criteria.scheme_criterion.scores.to_a.max_by(&:score).score * scheme_mix_criteria.scheme_criterion.weight / 100 * weight / 100
    end
    return weighted_max_attainable_score
  end

  def weighted_targeted_score_for_category(category)
    scheme_mix_criteria.for_category(category).joins(:scheme_criterion).sum('targeted_score * scheme_criteria.weight / 100')
  end

  def weighted_targeted_score
    scheme_mix_criteria.joins(:scheme_criterion).joins(:scheme_mix).sum('targeted_score * scheme_criteria.weight / 100 * scheme_mixes.weight / 100')
  end

  def weighted_submitted_score_for_category(category)
    scheme_mix_criteria.for_category(category).joins(:scheme_criterion).sum('submitted_score * scheme_criteria.weight / 100')
  end

  def weighted_submitted_score
    scheme_mix_criteria.joins(:scheme_criterion).joins(:scheme_mix).sum('submitted_score * scheme_criteria.weight / 100 * scheme_mixes.weight / 100')
  end

  private
    def create_descendant_records
      scheme.scheme_criteria.each do |scheme_criterion|
        scheme_mix_criterion = SchemeMixCriterion.create(targeted_score: 0, scheme_mix: self, scheme_criterion: scheme_criterion)

        scheme_criterion.requirements.each do |requirement|
          case requirement.reportable_type
            when 'Calculator'
              requirement.reportable.fields.each do |field|
                reportable_datum = RequirementDatum
                                    .joins("INNER JOIN scheme_mix_criteria_requirement_data ON scheme_mix_criteria_requirement_data.requirement_datum_id = requirement_data.id")
                                    .joins("INNER JOIN scheme_mix_criteria ON scheme_mix_criteria.id = scheme_mix_criteria_requirement_data.scheme_mix_criterion_id")
                                    .joins("INNER JOIN field_data ON field_data.id = requirement_data.reportable_data_id")
                                    .where("scheme_mix_criteria.scheme_mix_id = ?", self.id)
                                    .where("field_data.field_id = ?", field.id).first
                if reportable_datum.nil?
                  reportable_datum = FieldDatum.create(field_id: field.id)
                end
                scheme_mix_criterion.requirement_data.create(reportable_data_type: 'FieldDatum', reportable_data_id: reportable_datum.id)
              end
            when 'Document'
              reportable_datum = RequirementDatum
                                  .joins("INNER JOIN scheme_mix_criteria_requirement_data ON scheme_mix_criteria_requirement_data.requirement_datum_id = requirement_data.id")
                                  .joins("INNER JOIN scheme_mix_criteria ON scheme_mix_criteria.id = scheme_mix_criteria_requirement_data.scheme_mix_criterion_id")
                                  .joins("INNER JOIN document_data ON document_data.id = requirement_data.reportable_data_id")
                                  .where("scheme_mix_criteria.scheme_mix_id = ?", self.id)
                                  .where("document_data.document_id = ?", requirement.reportable_id).first
              if reportable_datum.nil?
                reportable_datum = DocumentDatum.create(document_id: requirement.reportable_id)
              end
              scheme_mix_criterion.requirement_data.create(reportable_data_type: 'DocumentDatum', reportable_data_id: reportable_datum.id)
          end
        end
      end
    end
  end
