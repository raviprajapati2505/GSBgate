module Auditable
  extend ActiveSupport::Concern

  AUDIT_LOG_CREATE = 0
  AUDIT_LOG_UPDATE = 1
  AUDIT_LOG_DESTROY = 2
  AUDIT_LOG_TOUCH = 3

  included do
    attr_accessor :audit_log_user_comment

    has_many :audit_logs, as: :auditable, dependent: :delete_all

    after_create :audit_log_create
    after_update :audit_log_update
    after_destroy :audit_log_destroy
    after_touch :audit_log_touch
  end

  private
  def audit_log_create
    audit_log(AUDIT_LOG_CREATE)
  end

  def audit_log_update
    audit_log(AUDIT_LOG_UPDATE)
  end

  def audit_log_destroy
    audit_log(AUDIT_LOG_DESTROY)
  end

  def audit_log_touch
    audit_log(AUDIT_LOG_TOUCH)
  end

  def audit_log(action)
    if User.current.blank?
      return
    end

    system_messages = []
    system_messages_params = []
    old_status = nil
    new_status = nil
    auditable = self

    case self.class.name
      when Project.name.demodulize
        project = self
        if (action == AUDIT_LOG_CREATE)
          system_messages << 'A new project %s was created.'
          system_messages_params << [self.name]
        elsif (action == AUDIT_LOG_UPDATE)
          system_messages << 'The project details of %s were updated.'
          system_messages_params << [self.name]
        end
      when ProjectsUser.name.demodulize
        auditable = self.project
        project = self.project
        if (action == AUDIT_LOG_CREATE)
          system_messages << 'User %s was added to project %s as a %s.'
          system_messages_params << [self.user.email, self.project.name, self.role.humanize]
        elsif (action == AUDIT_LOG_UPDATE)
          if self.role_changed?
            system_messages << 'The role of user %s in project %s was changed from %s to %s.'
            system_messages_params << [self.user.email, self.project.name, self.changes[:role][0].humanize, self.changes[:role][1].humanize]
          end
        elsif (action == AUDIT_LOG_DESTROY)
          system_messages << 'User %s was removed from project %s as a %s.'
          system_messages_params << [self.user.email, self.project.name, self.role.humanize]
        end
      when CertificationPath.name.demodulize
        project = self.project
        if self.certification_path_status_id_changed?
          old_status = self.changes[:certification_path_status_id][0]
          new_status = self.changes[:certification_path_status_id][1]
          old_status_model = CertificationPathStatus.find_by_id(old_status)
          new_status_model = CertificationPathStatus.find_by_id(new_status)
        end
        if (action == AUDIT_LOG_CREATE)
          system_messages << 'A new certification path %s was created in project %s.'
          system_messages_params << [self.name, self.project.name]
        elsif (action == AUDIT_LOG_UPDATE)
          if self.certification_path_status_id_changed?
            system_messages << 'The status of certification path %s in project %s was changed from %s to %s.'
            system_messages_params << [self.name, self.project.name, old_status_model.name, new_status_model.name]
          end
        end
        if (action == AUDIT_LOG_CREATE || action == AUDIT_LOG_UPDATE)
          if self.pcr_track_changed?
            if self.pcr_track?
              system_messages << 'A PCR track request was issued for the certification path %s in project %s.'
            else
              system_messages << 'The PCR track request was canceled for the certification path %s in project %s.'
            end
            system_messages_params << [self.name, self.project.name]
          end
          if self.pcr_track_allowed_changed?
            if self.pcr_track_allowed?
              system_messages << 'The PCR track request for certification path %s in project %s was granted.'
            else
              system_messages << 'The PCR track request for certification path %s in project %s was rejected.'
            end
            system_messages_params << [self.name, self.project.name]
          end
        end
      when SchemeMixCriterion.name.demodulize
        project = self.scheme_mix.certification_path.project
        if (action == AUDIT_LOG_UPDATE)
          if self.status_changed?
            system_messages << 'The status of criterion %s was changed from %s to %s.'
            system_messages_params << [self.name, self.changes[:status][0].humanize, self.changes[:status][1].humanize]
          elsif self.certifier_id_changed? or self.due_date_changed?
            if self.certifier_id.blank?
              system_messages << 'A GORD certifier was unassigned from criterion %s.'
              system_messages_params << [self.name]
            elsif self.due_date?
              system_messages << 'Criterion %s was assigned to GORD certifier %s for review. The due date is %s.'
              system_messages_params << [self.name, self.certifier.email, I18n.l(self.due_date, format: :short)]
            else
              system_messages << 'Criterion %s was assigned to GORD certifier %s for review.'
              system_messages_params << [self.name, self.certifier.email]
            end
          end
        end
      when SchemeMixCriteriaDocument.name.demodulize
        project = self.scheme_mix_criterion.scheme_mix.certification_path.project
        if (action == AUDIT_LOG_CREATE)
          system_messages << 'A new document %s was added to criterion %s.'
          system_messages_params << [self.name, self.scheme_mix_criterion.name]
        elsif (action == AUDIT_LOG_UPDATE)
          if self.status_changed?
            system_messages << 'The status of document %s in %s was changed from %s to %s.'
            system_messages_params << [self.name, self.scheme_mix_criterion.name, self.changes[:status][0].humanize, self.changes[:status][1].humanize]
          end
        end
      when RequirementDatum.name.demodulize
        if (action != AUDIT_LOG_CREATE)
          project = self.scheme_mix_criteria.take.scheme_mix.certification_path.project
        end
        if (action == AUDIT_LOG_UPDATE)
          if self.status_changed?
            system_messages << 'The status of requirement %s was changed from %s to %s.'
            system_messages_params << [self.name, self.changes[:status][0].humanize, self.changes[:status][1].humanize]
          end
          if self.user_id_changed? or self.due_date_changed?
            if self.user_id.blank?
              system_messages << 'A project team member was unassigned from requirement %s.'
              system_messages_params << [self.name]
            elsif self.due_date?
              system_messages << 'Requirement %s was assigned to %s. The due date is %s.'
              system_messages_params << [self.name, self.user.email, I18n.l(self.due_date, format: :short)]
            else
              system_messages << 'Requirement %s was assigned to %s.'
              system_messages_params << [self.name, self.user.email]
            end
          end
        end
    end

    # Format the user comment
    if self.audit_log_user_comment.present?
      user_comment = self.audit_log_user_comment
    else
      user_comment = nil
    end

    # Create the audit log record(s)
    if system_messages.present?
      system_messages.each_with_index do |system_message, index|
        AuditLog.create!(
            system_message: system_message.gsub('%s', '<strong>%s</strong>') % system_messages_params[index],
            user_comment: user_comment,
            old_status: old_status,
            new_status: new_status,
            user: User.current,
            auditable: auditable,
            project: project)
      end
    elsif user_comment.present?
      AuditLog.create!(
          system_message: nil,
          user_comment: user_comment,
          old_status: old_status,
          new_status: new_status,
          user: User.current,
          auditable: auditable,
          project: project)
    end
  end
end
