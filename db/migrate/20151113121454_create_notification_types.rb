class CreateNotificationTypes < ActiveRecord::Migration
  def up
    create_table :notification_types do |t|
      t.string :name

      t.timestamps null: false
    end

    NotificationType.create!(id: NotificationType::NEW_USER_COMMENT, name: 'New user comment')
    NotificationType.create!(id: NotificationType::PROJECT_CREATED, name: 'Project created')
    NotificationType.create!(id: NotificationType::CERTIFICATE_APPLIED, name: 'Certificate applied')
    NotificationType.create!(id: NotificationType::CERTIFICATE_ACTIVATED, name: 'Certificate activated')
    NotificationType.create!(id: NotificationType::CERTIFICATE_SUBMITTED_FOR_SCREENING, name: 'Certificate submitted for screening')
    NotificationType.create!(id: NotificationType::CERTIFICATE_SCREENED, name: 'Certificate screened')
    NotificationType.create!(id: NotificationType::CERTIFICATE_PCR_SELECTED, name: 'PCR for Certificate selected')
    NotificationType.create!(id: NotificationType::CERTIFICATE_PCR_APPROVED, name: 'PCR for Certificate approved')
    NotificationType.create!(id: NotificationType::CERTIFICATE_SUBMITTED_FOR_VERIFICATION, name: 'Certificate submitted for verification')
    NotificationType.create!(id: NotificationType::CERTIFICATE_VERIFIED, name: 'Certificate verified')
    NotificationType.create!(id: NotificationType::CERTIFICATE_APPEALED, name: 'Some criteria of Certificate are appealed')
    NotificationType.create!(id: NotificationType::CERTIFICATE_APPEAL_APPROVED, name: 'Certificate criteria appeal approved')
    NotificationType.create!(id: NotificationType::CERTIFICATE_SUBMITTED_FOR_VERIFICATION_AFTER_APPEAL, name: 'Certificate submitted after appeal')
    NotificationType.create!(id: NotificationType::CERTIFICATE_VERIFIED_AFTER_APPEAL, name: 'Certificate verified after appeal')
    NotificationType.create!(id: NotificationType::CERTIFICATE_APPROVED_BY_MNGT, name: 'Certificate approved by GORD management')
    NotificationType.create!(id: NotificationType::CERTIFICATE_ISSUED, name: 'Certificate issued')
    NotificationType.create!(id: NotificationType::CRITERION_SUBMITTED, name: 'Criterion submitted')
    NotificationType.create!(id: NotificationType::CRITERION_VERIFIED, name: 'Criterion verified')
    NotificationType.create!(id: NotificationType::CRITERION_APPEALED, name: 'Criterion appealed')
    NotificationType.create!(id: NotificationType::CRITERION_SUBMITTED_AFTER_APPEAL, name: 'Criterion submitted after appeal')
    NotificationType.create!(id: NotificationType::CRITERION_VERIFIED_AFTER_APPEAL, name: 'Criterion verified after appeal')
    NotificationType.create!(id: NotificationType::REQUIREMENT_PROVIDED, name: 'Requirement provided')
    NotificationType.create!(id: NotificationType::NEW_DOCUMENT_WAITING_FOR_APPROVAL, name: 'New document uploaded for criterion')
    NotificationType.create!(id: NotificationType::DOCUMENT_APPROVED, name: 'Document approved')
    NotificationType.create!(id: NotificationType::NEW_TASK, name: 'New task')
  end

  def down
    drop_table :notification_types
  end
end
