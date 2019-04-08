class RemoveCm21Issue3Projects < ActiveRecord::Migration[4.2]
  def change

    # Destroy all user data
    # =====================

    # See mail from Mohamed Osama from August 30th, 2017, 14:23 to find the list of projects below
    projects = Project.where(code: ['PC-QA-0021-0021-SC','PC-QA-0024-0024','PC-QA-0025-0025','PC-QA-0026-0026','PC-QA-0027-0027','PC-QA-0028-0028','PC-QA-0029-0029','PC-QA-0030-0030'])
    certification_paths = CertificationPath.where(project: projects)
    scheme_mixes = SchemeMix.where(certification_path: certification_paths)
    scheme_mix_criteria = SchemeMixCriterion.where(scheme_mix: scheme_mixes)

    # Destroy scheme_mix_criteria_documents
    destroyed_documents = SchemeMixCriteriaDocument.destroy_all(scheme_mix_criterion: scheme_mix_criteria)

    # Destroy documents
    Document.destroy_all(id: destroyed_documents.map { |document| document['document_id'] })

    # Destroy scheme_mix_criteria_requirement_data
    destroyed_data = SchemeMixCriteriaRequirementDatum.destroy_all(scheme_mix_criterion: scheme_mix_criteria)

    # Destroy requirement_data
    RequirementDatum.destroy_all(id: destroyed_data.map { |datum| datum['requirement_datum_id'] })

    # Destroy scheme_mix_criteria
    scheme_mix_criteria.destroy_all()

    # Destroy scheme_mixes
    scheme_mixes.destroy_all()

    # Destroy audit_logs
    AuditLog.destroy_all(certification_path: certification_paths)

    # Destroy certification_paths
    certification_paths.destroy_all()

  end
end
