class RequirementDatumTask < Task
  belongs_to :requirement_datum
  belongs_to :scheme_mix_criterion
  belongs_to :certification_path
end