class Certificate < ActiveRecord::Base
  enum certificate_type: [ :design_type, :construction_type, :operations_type ]
  enum assessment_stage: [ :design_stage, :construction_stage, :operations_stage ]

end
