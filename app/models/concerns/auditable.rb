module Auditable
  extend ActiveSupport::Concern
  include ActionView::Helpers

  AUDIT_LOG_CREATE = 0
  AUDIT_LOG_UPDATE = 1
  AUDIT_LOG_DESTROY = 2
  AUDIT_LOG_TOUCH = 3

  included do
    attr_accessor :audit_log_user_comment

    has_many :audit_logs, as: :auditable, dependent: :destroy

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
    begin
      if User.current.blank?
        return
      end

      system_messages = []
      project = nil
      certification_path = nil
      auditable = self

      case self.class.name.demodulize
        when Project.name.demodulize
          project = self
          if (action == AUDIT_LOG_CREATE)
            system_messages << {message: t('models.concerns.auditable.project.create_html', project: self.name)}
          elsif (action == AUDIT_LOG_UPDATE)
            system_messages << {message: t('models.concerns.auditable.project.update_html', project: self.name)}
          end
        when ProjectsUser.name.demodulize
          auditable = self.project
          project = self.project
          if (action == AUDIT_LOG_CREATE)
            system_messages << {message: t('models.concerns.auditable.projects_user.create_html', user: self.user.email, project: self.project.name, role: I18n.t(self.role, scope: 'activerecord.attributes.projects_user.roles'))}
          elsif (action == AUDIT_LOG_UPDATE)
            if self.role_changed?
              system_messages << {message: t('models.concerns.auditable.projects_user.update_html', user: self.user.email, project: self.project.name, role_old: I18n.t(self.role_was, scope: 'activerecord.attributes.projects_user.roles'), role_new: I18n.t(self.role, scope: 'activerecord.attributes.projects_user.roles'))}
            end
          elsif (action == AUDIT_LOG_DESTROY)
            system_messages << {message: t('models.concerns.auditable.projects_user.destroy_html', user: self.user.email, project: self.project.name, role: I18n.t(self.role, scope: 'activerecord.attributes.projects_user.roles'))}
          end
        when CertificationPath.name.demodulize
          project = self.project
          certification_path = self
          if self.certification_path_status_id_changed?
            old_status_model = CertificationPathStatus.find_by_id(self.status_was)
            new_status_model = CertificationPathStatus.find_by_id(self.status)
          end
          if (action == AUDIT_LOG_CREATE)
            system_messages << {message: t('models.concerns.auditable.certification_path.status.create_html', certification_path: self.name, project: self.project.name), old_status: self.status_was, new_status: self.status}
          elsif (action == AUDIT_LOG_UPDATE)
            if self.certification_path_status_id_changed?
              system_messages << {message: t('models.concerns.auditable.certification_path.status.update_html', certification_path: self.name, project: self.project.name, old_status: old_status_model.name, new_status: new_status_model.name), old_status: self.status_was, new_status: self.status}
            end
          end
          if (action == AUDIT_LOG_CREATE || action == AUDIT_LOG_UPDATE)
            if self.pcr_track_changed?
              if self.pcr_track?
                system_messages << {message: t('models.concerns.auditable.certification_path.pcr.issued_html', certification_path: self.name, project: self.project.name)}
              else
                system_messages << {message: t('models.concerns.auditable.certification_path.pcr.cancelled_html', certification_path: self.name, project: self.project.name)}
              end
            end
          end
        when SchemeMixCriterion.name.demodulize
          project = self.scheme_mix.certification_path.project
          certification_path = self.scheme_mix.certification_path
          system_messages_temp = []
          if (action == AUDIT_LOG_UPDATE)
            if self.status_changed?
              system_messages_temp << {message: t('models.concerns.auditable.scheme_mix_criterion.status.update_html', criterion: self.name, old_status: self.status_was.humanize, new_status: self.status.humanize), old_status: self.status_was, new_status: self.status}
            end
            if self.certifier_id_changed? || self.due_date_changed?
              if self.certifier_id.blank?
                system_messages_temp << {message: t('models.concerns.auditable.scheme_mix_criterion.certifier.unassigned_html', criterion: self.name)}
              elsif self.due_date?
                system_messages_temp << {message: t('models.concerns.auditable.scheme_mix_criterion.certifier.assigned_due_html', criterion: self.name, user: self.certifier.email, due_date: I18n.l(self.due_date, format: :short))}
              else
                system_messages_temp << {message: t('models.concerns.auditable.scheme_mix_criterion.certifier.assigned_html', criterion: self.name, user: self.certifier.email)}
              end
            end
            if self.targeted_score_changed?
              if self.targeted_score_was.nil?
                system_messages_temp << {message: t('models.concerns.auditable.scheme_mix_criterion.targeted_score.set_html', criterion: self.name, score: self.targeted_score)}
              elsif self.targeted_score.nil?
                system_messages_temp << {message: t('models.concerns.auditable.scheme_mix_criterion.targeted_score.unset_html', criterion: self.name)}
              else
                system_messages_temp << {message: t('models.concerns.auditable.scheme_mix_criterion.targeted_score.update_html', criterion: self.name, old_score: self.targeted_score_was, new_score: self.targeted_score)}
              end
            end
            if self.submitted_score_changed?
              if self.submitted_score_was.nil?
                system_messages_temp << {message: t('models.concerns.auditable.scheme_mix_criterion.submitted_score.set_html', criterion: self.name, score: self.submitted_score)}
              elsif self.submitted_score.nil?
                system_messages_temp << {message: t('models.concerns.auditable.scheme_mix_criterion.submitted_score.unset_html', criterion: self.name)}
              else
                system_messages_temp << {message: t('models.concerns.auditable.scheme_mix_criterion.submitted_score.update_html', criterion: self.name, old_score: self.submitted_score_was, new_score: self.submitted_score)}
              end
            end
            if self.achieved_score_changed?
              if self.achieved_score_was.nil?
                system_messages_temp << {message: t('models.concerns.auditable.scheme_mix_criterion.achieved_score.set_html', criterion: self.name, score: self.achieved_score)}
              elsif self.achieved_score.nil?
                system_messages_temp << {message: t('models.concerns.auditable.scheme_mix_criterion.achieved_score.unset_html', criterion: self.name)}
              else
                system_messages_temp << {message: t('models.concerns.auditable.scheme_mix_criterion.achieved_score.update_html',  criterion: self.name, old_score: self.achieved_score_was, new_score: self.achieved_score)}
              end
            end
          end
          # If the scheme mix criterion inherits from a criterion in the main scheme mix,
          # notify the user that the changes were automated.
          if self.main_scheme_mix_criterion_id.present?
            system_messages_temp.each_with_index do |index, value|
              system_messages_temp[index] = value + ' ' + t('models.concerns.auditable.scheme_mix_criterion.main.update_html', main_criterion: self.main_scheme_mix_criterion.full_name, main_scheme: self.scheme_mix.certification_path.main_scheme_mix.name)
            end
          end
          system_messages = system_messages + system_messages_temp
        when SchemeMixCriteriaDocument.name.demodulize
          project = self.scheme_mix_criterion.scheme_mix.certification_path.project
          certification_path = self.scheme_mix_criterion.scheme_mix.certification_path
          if (action == AUDIT_LOG_CREATE)
            system_messages << {message: t('models.concerns.auditable.scheme_mix_criteria_document.status.create_html', document: self.name, criterion: self.scheme_mix_criterion.name), old_status: self.status_was, new_status: self.status}
          elsif (action == AUDIT_LOG_UPDATE)
            if self.status_changed?
              system_messages << {message: t('models.concerns.auditable.scheme_mix_criteria_document.status.update_html', document: self.name, criterion: self.scheme_mix_criterion.name, old_status: self.status_was.humanize, new_status: self.status.humanize), old_status: self.status_was, new_status: self.status}
            end
          end
        when RequirementDatum.name.demodulize
          if (action != AUDIT_LOG_CREATE)
            project = self.scheme_mix_criteria.take.scheme_mix.certification_path.project
            certification_path = self.scheme_mix_criteria.take.scheme_mix.certification_path
          end
          if (action == AUDIT_LOG_UPDATE)
            if self.status_changed?
              system_messages << {message: t('models.concerns.auditable.requirement_datum.status.update_html', requirement: self.name, old_status: self.status_was.humanize, new_status: self.status.humanize), old_status: self.status_was, new_status: self.status}
            end
            if self.user_id_changed? || self.due_date_changed?
              if self.user_id.blank?
                system_messages << {message: t('models.concerns.auditable.requirement_datum.user.unassigned_html', requirement: self.name)}
              elsif self.due_date?
                system_messages << {message: t('models.concerns.auditable.requirement_datum.user.assigned_due_html', requirement: self.name, user: self.user.email, due_date: I18n.l(self.due_date, format: :short))}
              else
                system_messages << {message: t('models.concerns.auditable.requirement_datum.user.assigned_html', requirement: self.name, user: self.user.email)}
              end
            end
          end
        when SchemeCriterionText.name.demodulize
          auditable = self.scheme_criterion
          if (action == AUDIT_LOG_CREATE)
            system_messages << {message: t('models.concerns.auditable.scheme_criterion_text.status.create_html', text: self.name, criterion: self.scheme_criterion.full_name)}
          elsif (action == AUDIT_LOG_UPDATE)
            system_messages << {message: t('models.concerns.auditable.scheme_criterion_text.status.update_html', text: self.name, criterion: self.scheme_criterion.full_name)}
          elsif (action == AUDIT_LOG_DESTROY)
            system_messages << {message: t('models.concerns.auditable.scheme_criterion_text.status.destroy_html', text: self.name, criterion: self.scheme_criterion.full_name)}
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
              system_message: system_message[:message],
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
    rescue NoMethodError
    end
  end
end
