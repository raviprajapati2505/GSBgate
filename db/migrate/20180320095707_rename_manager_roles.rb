class RenameManagerRoles < ActiveRecord::Migration[4.2]
  def change
    CertificationPathStatus.where(id: CertificationPathStatus::APPROVING_BY_MANAGEMENT).update_all(name: 'Approving by Head of GSAS', past_name: 'Approved by Head of GSAS', description: 'The GSAS trust team approved this certification. The Head of GSAS will now approve the certification and advance the status.')
    CertificationPathStatus.where(id: CertificationPathStatus::APPROVING_BY_TOP_MANAGEMENT).update_all(name: 'Approving by Chairman', past_name: 'Approved by Chairman', description: 'The Head of GSAS approved this certification. The Chairman will now approve the certification and advance the status.')

    NotificationType.where(id: NotificationType::CERTIFICATE_APPROVED_BY_MNGT).update_all(name: 'certification approved by Head of GSAS')
    NotificationType.where(id: NotificationType::CERTIFICATE_APPROVED_BY_TOP_MNGT).update_all(name: 'certification approved by Chairman')

    audit_logs = AuditLog.where("system_message LIKE '%by top management%'")
    audit_logs.each do |audit_log|
      audit_log.update_column(:system_message, audit_log.system_message.gsub('by top management', 'by Chairman'))
    end

    audit_logs = AuditLog.where("system_message LIKE '%by management%'")
    audit_logs.each do |audit_log|
      audit_log.update_column(:system_message, audit_log.system_message.gsub('by management', 'by Head of GSAS'))
    end
  end
end
