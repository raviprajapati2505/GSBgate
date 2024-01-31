CertificationPathStatus.find_or_create_by!(
  id: CertificationPathStatus::ACTIVATING, 
  name: 'Activating', 
  past_name: 'Activated', 
  description: "The certification is registered. After payment is received, a GSAS trust administrator will advance the status of the certification."
)

CertificationPathStatus.find_or_create_by!(
  id: CertificationPathStatus::SUBMITTING, 
  name: "Submitting",
  past_name: "Submitted",
  description:
   "The certification is activated by a GSAS trust administrator. The project team can now provide the requirements for all criteria and set the submitted scores of all criteria. When all criteria are completed, a CGP project manager will advance the status of the certification."
)

CertificationPathStatus.find_or_create_by!(
  id: CertificationPathStatus::SCREENING, 
  name: "Screening",
  past_name: "Screened",
  description:
   "The project team has completed all criteria. After the GSAS trust team has screened the criteria input, a GSAS trust certification manager will advance the status of the certification and provide screening comments."
)

CertificationPathStatus.find_or_create_by!(
  id: CertificationPathStatus::SUBMITTING_AFTER_SCREENING, 
  name: "Submitting after screening",
  past_name: "Submitted after screening",
  description:
   "The GSAS trust team has screened and commented the criteria input. The project team can process this feedback by editing the existing criteria input. When all criteria are completed, a CGP project manager will advance the status of the certification."
)

CertificationPathStatus.find_or_create_by!(
  id: CertificationPathStatus::VERIFYING, 
  name: "Verifying",
  past_name: "Verified",
  description:
   "The project team has completed all criteria. The GSAS trust team will now review all criteria input and set the the achieved scores of the criteria. After all criteria are verified, a GSAS trust certification manager will advance the status of the certification."
)

CertificationPathStatus.find_or_create_by!(
  id: CertificationPathStatus::ACKNOWLEDGING, 
  name: "Acknowledging",
  past_name: "Acknowledged",
  description: "The GSAS trust team has verified all criteria. A CGP project manager will now decide to accept all scores or apply for appeal. After this, the certification status will be advanced."
)

CertificationPathStatus.find_or_create_by!(
  id: CertificationPathStatus::PROCESSING_APPEAL_PAYMENT, 
  name: "Processing appeal payment",
  past_name: "Appeal payment processed",
  description: "An appeal was requested by a CGP project manager. After payment is received, a GSAS trust administrator will advance the status of the certification."
)

CertificationPathStatus.find_or_create_by!(
  id: CertificationPathStatus::SUBMITTING_AFTER_APPEAL, 
  name: "Submitting after appeal",
  past_name: "Submitted after appeal",
  description:
   "An appeal was requested by a CGP project manager. The project team can now (re)provide the requirements for all criteria and set the submitted scores of all criteria. When all criteria are completed, a CGP project manager can advance the status of the certification."
)

CertificationPathStatus.find_or_create_by!(
  id: CertificationPathStatus::VERIFYING_AFTER_APPEAL, 
  name: "Verifying after appeal",
  past_name: "Verified after appeal",
  description:
   "The project team has completed all criteria. The GSAS trust team will now review all criteria input and set the the achieved scores of the criteria. After all criteria are reviewed, a GSAS trust certification manager will advance the status of the certification."
)

CertificationPathStatus.find_or_create_by!(
  id: CertificationPathStatus::ACKNOWLEDGING_AFTER_APPEAL, 
  name: "Acknowledging after appeal",
  past_name: "Acknowledged after appeal",
  description: "The GSAS trust team has verified all criteria. After a CGP project manager acknowledges the achieved scores, he will advance the status of the certification."
)

CertificationPathStatus.find_or_create_by!(
  id: CertificationPathStatus::APPROVING_BY_MANAGEMENT, 
  name: "Approving by Director of GSAS Trust",
  past_name: "Approved by Director of GSAS Trust",
  description: "The GSAS trust team approved this certification. The Director of GSAS will now approve the certification and advance the status."
)

CertificationPathStatus.find_or_create_by!(
  id: CertificationPathStatus::APPROVING_BY_TOP_MANAGEMENT, 
  name: "Approving by Chairman",
  past_name: "Approved by Chairman",
  description: "Director of GSAS Trust approved this certification. The Chairman will now approve the certification and advance the status."
)

CertificationPathStatus.find_or_create_by!(
  id: CertificationPathStatus::CERTIFIED, 
  name: "Certified",
  past_name: "Certified",
  description: "The GSAS trust team has issued this certification."
)

CertificationPathStatus.find_or_create_by!(
  id: CertificationPathStatus::NOT_CERTIFIED, 
  name: "Not certified",
  past_name: "Not certified",
  description: "The GSAS trust team has denied this certification."
)

CertificationPathStatus.find_or_create_by!(
  id: CertificationPathStatus::CERTIFICATE_IN_PROCESS, 
  name: "Certificate In Process",
  past_name: "Certificate Generated",
  description: "Certificate In Process - after Chairman approval"
)

puts "Certification Path Status are added successfully.........."

