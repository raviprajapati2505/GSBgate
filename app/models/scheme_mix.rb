class SchemeMix < ActiveRecord::Base
  belongs_to :certification_path
  belongs_to :scheme
  has_many :scheme_mix_criteria

  after_create :create_descendant_records

  private
    def create_descendant_records
      scheme.scheme_criteria.each do |scheme_criterion|
        scheme_mix_criterion = SchemeMixCriterion.create(targeted_score: 0, scheme_mix: self, scheme_criterion: scheme_criterion)

        scheme_criterion.requirements.each do |requirement|
          case requirement.reportable_type
          when 'Calculator'
            reportable_datum = FieldDatum.create(field_id: requirement.reportable_id)
            scheme_mix_criterion.requirement_data.create(reportable_data_type: 'FieldDatum', reportable_data_id: reportable_datum.id)
          when 'Document'
            reportable_datum = DocumentDatum.create(document_id: requirement.reportable_id)
            scheme_mix_criterion.requirement_data.create(reportable_data_type: 'DocumentDatum', reportable_data_id: reportable_datum.id)
          end
        end
      end
    end
  end
