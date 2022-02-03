CertificationPath.with_status_not(CertificationPathStatus::CERTIFIED).each do |certification_path|
  begin
    certificatation_path_report = CertificatationPathReport.find_or_initialize_by(
                                    certification_path_id: certification_path.id
                                  )

    certificatation_path_report.save(validate: false)
  rescue StanderdError => e
    puts e&.message
  end  
end