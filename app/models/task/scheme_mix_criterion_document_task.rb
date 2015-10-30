class SchemeMixCriterionDocumentTask < Task
  belongs_to :scheme_mix_criteria_document
  belongs_to :scheme_mix_criterion
  belongs_to :certification_path
end