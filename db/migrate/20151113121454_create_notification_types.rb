class CreateNotificationTypes < ActiveRecord::Migration
  def up
    create_table :notification_types do |t|
      t.string :name

      t.timestamps null: false
    end

    NotificationType.create!(id: NotificationType::NEW_USER_COMMENT, name: 'New user comment', project_level: true)
    NotificationType.create!(id: NotificationType::PROJECT_CREATED, name: 'Project created', project_level: false)
    NotificationType.create!(id: NotificationType::CERTIFICATE_APPLIED, name: 'Certificate applied', project_level: true)
    NotificationType.create!(id: NotificationType::CERTIFICATE_ACTIVATED, name: 'Certificate activated', project_level: true)
    NotificationType.create!(id: NotificationType::CERTIFICATE_SUBMITTED_FOR_SCREENING, name: 'Certificate submitted for screening', project_level: true)
    NotificationType.create!(id: NotificationType::CERTIFICATE_SCREENED, name: 'Certificate screened', project_level: true)
    NotificationType.create!(id: NotificationType::CERTIFICATE_PCR_SELECTED, name: 'PCR for Certificate selected', project_level: true)
    NotificationType.create!(id: NotificationType::CERTIFICATE_PCR_APPROVED, name: 'PCR for Certificate approved', project_level: true)
    NotificationType.create!(id: NotificationType::CERTIFICATE_SUBMITTED_FOR_VERIFICATION, name: 'Certificate submitted for verification', project_level: true)
    NotificationType.create!(id: NotificationType::CERTIFICATE_VERIFIED, name: 'Certificate verified', project_level: true)
    NotificationType.create!(id: NotificationType::CERTIFICATE_APPEALED, name: 'Some criteria of Certificate are appealed', project_level: true)
    NotificationType.create!(id: NotificationType::CERTIFICATE_APPEAL_APPROVED, name: 'Certificate criteria appeal approved', project_level: true)
    NotificationType.create!(id: NotificationType::CERTIFICATE_SUBMITTED_FOR_VERIFICATION_AFTER_APPEAL, name: 'Certificate submitted after appeal', project_level: true)
    NotificationType.create!(id: NotificationType::CERTIFICATE_VERIFIED_AFTER_APPEAL, name: 'Certificate verified after appeal', project_level: true)
    NotificationType.create!(id: NotificationType::CERTIFICATE_APPROVED_BY_MNGT, name: 'Certificate approved by GORD management', project_level: true)
    NotificationType.create!(id: NotificationType::CERTIFICATE_ISSUED, name: 'Certificate issued', project_level: true)
    NotificationType.create!(id: NotificationType::CRITERION_SUBMITTED, name: 'Criterion submitted', project_level: true)
    NotificationType.create!(id: NotificationType::CRITERION_VERIFIED, name: 'Criterion verified', project_level: true)
    NotificationType.create!(id: NotificationType::CRITERION_APPEALED, name: 'Criterion appealed', project_level: true)
    NotificationType.create!(id: NotificationType::CRITERION_SUBMITTED_AFTER_APPEAL, name: 'Criterion submitted after appeal', project_level: true)
    NotificationType.create!(id: NotificationType::CRITERION_VERIFIED_AFTER_APPEAL, name: 'Criterion verified after appeal', project_level: true)
    NotificationType.create!(id: NotificationType::REQUIREMENT_PROVIDED, name: 'Requirement provided', project_level: true)
    NotificationType.create!(id: NotificationType::NEW_DOCUMENT_WAITING_FOR_APPROVAL, name: 'New document uploaded for criterion', project_level: true)
    NotificationType.create!(id: NotificationType::DOCUMENT_APPROVED, name: 'Document approved', project_level: true)
    NotificationType.create!(id: NotificationType::NEW_TASK, name: 'New task', project_level: false)
  end

  def down
    drop_table :notification_types
  end
end
