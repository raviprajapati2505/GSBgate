class RemoveCm20Certificates < ActiveRecord::Migration
  def change
    # Destroy all user data
    # =====================

    certificates = Certificate.where(certificate_type: 1, gsas_version: '2.0')
    certification_paths = CertificationPath.where(certificate: certificates)
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

    # Destroy all structural data
    # ===========================

    development_types = DevelopmentType.where(certificate: certificates)

    # Destroy development_type_schemes
    DevelopmentTypeScheme.destroy_all(development_type: development_types)

    # Destroy development_types
    development_types.destroy_all()

    # Destroy certificates
    certificates.destroy_all()

    schemes = Scheme.where(certificate_type: 1, gsas_version: '2.0')
    scheme_categories = SchemeCategory.where(scheme: schemes)
    scheme_criteria = SchemeCriterion.where(scheme_category: scheme_categories)

    # Destroy scheme_criteria_requirements
    destroyed_requirements = SchemeCriteriaRequirement.destroy_all(scheme_criterion: scheme_criteria)

    # Destroy requirements
    Requirement.destroy_all(id: destroyed_requirements.map { |requirement| requirement['requirement_id'] })

    # Destroy scheme_criteria_texts
    SchemeCriterionText.destroy_all(scheme_criterion: scheme_criteria)

    # Destroy scheme_criteria
    scheme_criteria.destroy_all()

    # Destroy scheme_categories
    scheme_categories.destroy_all()

    # Destroy schemes
    schemes.destroy_all()
  end
end
