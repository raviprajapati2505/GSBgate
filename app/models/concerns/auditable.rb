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
    project = nil
    certification_path = nil
    old_status = nil
    new_status = nil
    auditable = self

    case self.class.name
      when Project.name.demodulize
        project = self
        if (action == AUDIT_LOG_CREATE)
          system_messages << {message: 'A new project %s was created.', params: [self.name]}
        elsif (action == AUDIT_LOG_UPDATE)
          system_messages << {message: 'The project details of %s were updated.', params: [self.name]}
        end
      when ProjectsUser.name.demodulize
        auditable = self.project
        project = self.project
        if (action == AUDIT_LOG_CREATE)
          system_messages << {message: 'User %s was added to project %s as a %s.', params: [self.user.email, self.project.name, self.role.humanize]}
        elsif (action == AUDIT_LOG_UPDATE)
          if self.role_changed?
            system_messages << {message: 'The role of user %s in project %s was changed from %s to %s.', params: [self.user.email, self.project.name, self.changes[:role][0].humanize, self.changes[:role][1].humanize]}
          end
        elsif (action == AUDIT_LOG_DESTROY)
          system_messages << {message: 'User %s was removed from project %s as a %s.', params: [self.user.email, self.project.name, self.role.humanize]}
        end
      when CertificationPath.name.demodulize
        project = self.project
        certification_path = self
        if self.certification_path_status_id_changed?
          old_status = self.changes[:certification_path_status_id][0]
          new_status = self.changes[:certification_path_status_id][1]
          old_status_model = CertificationPathStatus.find_by_id(old_status)
          new_status_model = CertificationPathStatus.find_by_id(new_status)
        end
        if (action == AUDIT_LOG_CREATE)
          system_messages << {message: 'A new certificate %s was created in project %s.', params: [self.name, self.project.name], old_status: old_status, new_status: new_status}
        elsif (action == AUDIT_LOG_UPDATE)
          if self.certification_path_status_id_changed?
            system_messages << {message: 'The status of certificate %s in project %s was changed from %s to %s.', params: [self.name, self.project.name, old_status_model.name, new_status_model.name], old_status: old_status, new_status: new_status}
          end
        end
        if (action == AUDIT_LOG_CREATE || action == AUDIT_LOG_UPDATE)
          if self.pcr_track_changed?
            if self.pcr_track?
              system_messages << {message: 'A PCR track request was issued for the certificate %s in project %s.', params: [self.name, self.project.name]}
            else
              system_messages << {message: 'The PCR track request was canceled for the certificate %s in project %s.', params: [self.name, self.project.name]}
            end
          end
          if self.pcr_track_allowed_changed?
            if self.pcr_track_allowed?
              system_messages << {message: 'The PCR track request for certificate %s in project %s was granted.', params: [self.name, self.project.name]}
            else
              system_messages << {message: 'The PCR track request for certificate %s in project %s was rejected.', params: [self.name, self.project.name]}
            end
          end
        end
      when SchemeMixCriterion.name.demodulize
        project = self.scheme_mix.certification_path.project
        certification_path = self.scheme_mix.certification_path
        if (action == AUDIT_LOG_UPDATE)
          if self.status_changed?
            system_messages << {message: 'The status of criterion %s was changed from %s to %s.', params: [self.name, self.changes[:status][0].humanize, self.changes[:status][1].humanize]}
          elsif self.certifier_id_changed? or self.due_date_changed?
            if self.certifier_id.blank?
              system_messages << {message: 'A GORD certifier was unassigned from criterion %s.', params: [self.name]}
            elsif self.due_date?
              system_messages << {message: 'Criterion %s was assigned to GORD certifier %s for review. The due date is %s.', params: [self.name, self.certifier.email, I18n.l(self.due_date, format: :short)]}
            else
              system_messages << {message: 'Criterion %s was assigned to GORD certifier %s for review.', params: [self.name, self.certifier.email]}
            end
          end
        end
      when SchemeMixCriteriaDocument.name.demodulize
        project = self.scheme_mix_criterion.scheme_mix.certification_path.project
        certification_path = self.scheme_mix_criterion.scheme_mix.certification_path
        if (action == AUDIT_LOG_CREATE)
          system_messages << {message: 'A new document %s was added to criterion %s.', params: [self.name, self.scheme_mix_criterion.name]}
        elsif (action == AUDIT_LOG_UPDATE)
          if self.status_changed?
            system_messages << {message: 'The status of document %s in %s was changed from %s to %s.', params: [self.name, self.scheme_mix_criterion.name, self.changes[:status][0].humanize, self.changes[:status][1].humanize]}
          end
        end
      when RequirementDatum.name.demodulize
        if (action != AUDIT_LOG_CREATE)
          project = self.scheme_mix_criteria.take.scheme_mix.certification_path.project
          certification_path = self.scheme_mix_criteria.take.scheme_mix.certification_path
        end
        if (action == AUDIT_LOG_UPDATE)
          if self.status_changed?
            system_messages << {message: 'The status of requirement %s was changed from %s to %s.', params: [self.name, self.changes[:status][0].humanize, self.changes[:status][1].humanize]}
          end
          if self.user_id_changed? or self.due_date_changed?
            if self.user_id.blank?
              system_messages << {message: 'A project team member was unassigned from requirement %s.', params: [self.name]}
            elsif self.due_date?
              system_messages << {message: 'Requirement %s was assigned to %s. The due date is %s.', params: [self.name, self.user.email, I18n.l(self.due_date, format: :short)]}
            else
              system_messages << {message: 'Requirement %s was assigned to %s.', params: [self.name, self.user.email]}
            end
          end
        end
      when SchemeCriterionText.name.demodulize
        auditable = self.scheme_criterion
        if (action == AUDIT_LOG_CREATE)
          system_messages << {message: 'Criterion text %s in %s was created.', params: [self.name, self.scheme_criterion.full_name]}
        elsif (action == AUDIT_LOG_UPDATE)
          system_messages << {message: 'Criterion text %s in %s was edited.', params: [self.name, self.scheme_criterion.full_name]}
        elsif (action == AUDIT_LOG_DESTROY)
          system_messages << {message: 'Criterion text %s in %s was removed.', params: [self.name, self.scheme_criterion.full_name]}
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
      system_messages.each do |system_message|
        AuditLog.create!(
            system_message: system_message[:message].gsub('%s', '<strong>%s</strong>') % system_message[:params],
            user_comment: user_comment,
            old_status: system_message.has_key?(:old_status) ? system_message[:old_status] : nil,
            new_status: system_message.has_key?(:new_status) ? system_message[:new_status] : nil,
            user: User.current,
            auditable: auditable,
            certification_path: certification_path,
            project: project)
      end
    elsif user_comment.present?
      AuditLog.create!(
          user_comment: user_comment,
          user: User.current,
          auditable: auditable,
          certification_path: certification_path,
          project: project)
    end
  end
end
