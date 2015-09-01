class Task

  @@resource_types = {certification_path: 0, scheme_mix_criterion: 1, requirement_datum: 2, scheme_mix_criteria_document: 3}

  def initialize(project_id:,
                 certification_path_id: nil,
                 scheme_mix_id: nil,
                 scheme_mix_criterion_id: nil,
                 requirement_datum_id: nil,
                 scheme_mix_criteria_document_id: nil,
                 description_id:,
                 resource_name:,
                 resource_type:)
    # unique resource identification
    @project_id = project_id
    @certification_path_id = certification_path_id
    @scheme_mix_id = scheme_mix_id
    @scheme_mix_criterion_id = scheme_mix_criterion_id
    @requirement_datum_id = requirement_datum_id
    @scheme_mix_criteria_document_id = scheme_mix_criteria_document_id

    # description
    @description_id = description_id
    @resource_name = resource_name
    @resource_type = resource_type
  end

  def self.resource_types
    @@resource_types
  end

  def project_id
    @project_id
  end

  def certification_path_id
    @certification_path_id
  end

  def scheme_mix_id
    @scheme_mix_id
  end

  def scheme_mix_criterion_id
    @scheme_mix_criterion_id
  end

  def requirement_datum_id
    @requirement_datum_id
  end

  def scheme_mix_criteria_document_id
    @scheme_mix_criteria_document_id
  end

  def description_id
    @description_id
  end

  def resource_name
    @resource_name
  end

  def resource_type
    @resource_type
  end

end