CertificationPath.with_status(CertificationPathStatus::CERTIFIED).each do |certification_path|
  begin
    certificatation_path_report = CertificatationPathReport.find_or_initialize_by(
                                    certification_path_id: certification_path.id,
                                    to: certification_path.project.owner, 
                                    reference_number: certification_path.project.code, 
                                    project_owner: certification_path.project.owner, 
                                    project_name: certification_path.project.name, 
                                    project_location: certification_path.project.location, 
                                    issuance_date: certification_path.certified_at&.to_date, 
                                    approval_date: certification_path.certified_at&.to_date
                                  )

    certificatation_path_report.save(validate: false)
  rescue StanderdError => e
    puts e&.message
  end  
end