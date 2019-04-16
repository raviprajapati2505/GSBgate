module Auditable
  extend ActiveSupport::Concern
  include ActionView::Helpers::TranslationHelper

  AUDIT_LOG_CREATE = 0
  AUDIT_LOG_UPDATE = 1
  AUDIT_LOG_DESTROY = 2
  AUDIT_LOG_TOUCH = 3

  included do
    attr_accessor :audit_log_user_comment
    attr_accessor :audit_log_attachment_file
    attr_accessor :audit_log_visibility
    attr_accessor :audit_log_errors

    has_many :audit_logs, as: :auditable, dependent: :destroy

    after_create :audit_log_create
    after_update :audit_log_update
    after_destroy :audit_log_destroy
    after_touch :audit_log_touch
  end

  def get_project
    project = nil
    case self.class.name.demodulize
      when Project.name.demodulize
        project = self
      when ProjectsUser.name.demodulize
        project = self.project
      when CertificationPath.name.demodulize
        project = self.project
      when SchemeMixCriterion.name.demodulize
        project = self.scheme_mix.certification_path.project
      when SchemeMixCriteriaDocument.name.demodulize
        project = self.scheme_mix_criterion.scheme_mix.certification_path.project
      when RequirementDatum.name.demodulize
        project = self.scheme_mix_criteria.take.scheme_mix.certification_path.project
      when SchemeCriterionText.name.demodulize
        project = self.scheme_criterion.scheme_mix_criteria.scheme_mix.certification_path.project
      when CgpCertificationPathDocument.name.demodulize
        project = self.certification_path.project
      when CertifierCertificationPathDocument.name.demodulize
        project = self.certification_path.project
    end
    return project
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
      force_visibility_public = false

      case self.class.name.demodulize
        when Project.name.demodulize
          project = self
          if (action == AUDIT_LOG_CREATE)
            force_visibility_public = true
            system_messages << {message: t('models.concerns.auditable.project.create_html', project: self.name)}
          elsif (action == AUDIT_LOG_UPDATE)
            system_messages << {message: t('models.concerns.auditable.project.update_html', project: self.name)}
          end
        when ProjectsUser.name.demodulize
          auditable = self.project
          project = self.project
          if (action == AUDIT_LOG_CREATE)
            system_messages << {message: t('models.concerns.auditable.projects_user.create_html', user: self.user.full_name, project: self.project.name, role: t(self.role, scope: 'activerecord.attributes.projects_user.roles'))}
          elsif (action == AUDIT_LOG_UPDATE)
            if self.saved_change_to_role?
              system_messages << {message: t('models.concerns.auditable.projects_user.update_html', user: self.user.full_name, project: self.project.name, role_old: t(self.role_before_last_save, scope: 'activerecord.attributes.projects_user.roles'), role_new: t(self.role, scope: 'activerecord.attributes.projects_user.roles'))}
            end
          elsif (action == AUDIT_LOG_DESTROY)
            system_messages << {message: t('models.concerns.auditable.projects_user.destroy_html', user: self.user.full_name, project: self.project.name, role: t(self.role, scope: 'activerecord.attributes.projects_user.roles'))}
          end
        when CertificationPath.name.demodulize
          project = self.project
          certification_path = self
          if self.saved_change_to_certification_path_status_id?
            old_status_model = CertificationPathStatus.find_by_id(self.certification_path_status_id_before_last_save)
            new_status_model = CertificationPathStatus.find_by_id(self.certification_path_status_id)
            # generate publicly visible AuditLog record
            force_visibility_public = true
            if old_status_model.present? && CertificationPathStatus::STATUSES_IN_VERIFICATION.include?(old_status_model.id)
              # generate a audit log for all linked scheme mix criteria
              self.scheme_mix_criteria.each do |scheme_mix_criterion|
                AuditLog.create!(system_message: t('models.concerns.auditable.scheme_mix_criterion.status.after_verification', criterion: scheme_mix_criterion.name, new_status: t(scheme_mix_criterion.status, scope: 'activerecord.attributes.scheme_mix_criterion.statuses'), achieved_score: scheme_mix_criterion.achieved_score),
                                 user_comment: nil,
                                 old_status: nil,
                                 new_status: scheme_mix_criterion.status,
                                 user: User.current,
                                 auditable: scheme_mix_criterion,
                                 certification_path: certification_path,
                                 project: project,
                                 audit_log_visibility_id: AuditLogVisibility::PUBLIC)
              end
            end
          end
          if (action == AUDIT_LOG_CREATE)
            system_messages << {message: t('models.concerns.auditable.certification_path.status.create_html', certification_path: self.name, project: self.project.name), old_status: nil, new_status: self.certification_path_status_id}
          elsif (action == AUDIT_LOG_UPDATE)
            if self.saved_change_to_certification_path_status_id?
              system_messages << {message: t('models.concerns.auditable.certification_path.status.update_html', certification_path: self.name, project: self.project.name, old_status: old_status_model.name, new_status: new_status_model.name), old_status: self.certification_path_status_id_before_last_save, new_status: self.certification_path_status_id}
            elsif self.saved_change_to_signed_certificate_file?
              force_visibility_public = true
              system_messages << {message: t('models.concerns.auditable.certification_path.signed_certificate.update_html', document: self.signed_certificate_file.file.filename)}
            end
          end
          if action == AUDIT_LOG_UPDATE
            if self.saved_change_to_pcr_track?
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
            if self.saved_change_to_status?
              system_messages_temp << {message: t('models.concerns.auditable.scheme_mix_criterion.status.update_html', criterion: self.name, old_status: t(self.status_before_last_save, scope: 'activerecord.attributes.scheme_mix_criterion.statuses'), new_status: t(self.status, scope: 'activerecord.attributes.scheme_mix_criterion.statuses'))}
            end
            if self.saved_change_to_screened? && self.screened
              system_messages_temp << {message: t('models.concerns.auditable.scheme_mix_criterion.screened.update_html', criterion: self.name)}
            end
            if self.saved_change_to_in_review?
              if self.in_review?
                system_messages_temp << {message: t('models.concerns.auditable.scheme_mix_criterion.in_review.requested_html', criterion: self.name)}
              else
                system_messages_temp << {message: t('models.concerns.auditable.scheme_mix_criterion.in_review.provided_html', criterion: self.name)}
              end
            end
            if self.saved_change_to_pcr_review_draft?
              system_messages_temp << {message: t('models.concerns.auditable.scheme_mix_criterion.pcr_review_draft.update_html', criterion: self.name)}
            end
            if self.saved_change_to_certifier_id? || self.saved_change_to_due_date?
              if certification_path.in_verification?
                if self.certifier_id.blank?
                  system_messages_temp << {message: t('models.concerns.auditable.scheme_mix_criterion.certifier.unassigned_html', criterion: self.name)}
                elsif self.due_date?
                  system_messages_temp << {message: t('models.concerns.auditable.scheme_mix_criterion.certifier.assigned_for_verification_due_html', criterion: self.name, user: self.certifier.full_name, due_date: l(self.due_date, format: :short))}
                else
                  system_messages_temp << {message: t('models.concerns.auditable.scheme_mix_criterion.certifier.assigned_for_verification_html', criterion: self.name, user: self.certifier.full_name)}
                end
              elsif certification_path.in_screening?
                if self.certifier_id.blank?
                  system_messages_temp << {message: t('models.concerns.auditable.scheme_mix_criterion.certifier.unassigned_html', criterion: self.name)}
                elsif self.due_date?
                  system_messages_temp << {message: t('models.concerns.auditable.scheme_mix_criterion.certifier.assigned_for_screening_due_html', criterion: self.name, user: self.certifier.full_name, due_date: l(self.due_date, format: :short))}
                else
                  system_messages_temp << {message: t('models.concerns.auditable.scheme_mix_criterion.certifier.assigned_for_screening_html', criterion: self.name, user: self.certifier.full_name)}
                end
              elsif certification_path.in_submission?
                if self.certifier_id.blank?
                  system_messages_temp << {message: t('models.concerns.auditable.scheme_mix_criterion.certifier.unassigned_html', criterion: self.name)}
                elsif self.due_date?
                  system_messages_temp << {message: t('models.concerns.auditable.scheme_mix_criterion.certifier.assigned_for_pcr_review_due_html', criterion: self.name, user: self.certifier.full_name, due_date: l(self.due_date, format: :short))}
                else
                  system_messages_temp << {message: t('models.concerns.auditable.scheme_mix_criterion.certifier.assigned_for_pcr_review_html', criterion: self.name, user: self.certifier.full_name)}
                end
              end
            end
            SchemeMixCriterion::TARGETED_SCORE_ATTRIBUTES.each_with_index do |targeted_score, index|
              if self.send("saved_change_to_#{targeted_score}?")
                if self.send("#{targeted_score}_before_last_save").nil?
                  system_messages_temp << {message: t('models.concerns.auditable.scheme_mix_criterion.targeted_score.set_html', score_label: self.scheme_criterion.read_attribute(SchemeCriterion::LABEL_ATTRIBUTES[index].to_sym) || '', criterion: self.name, score: self.read_attribute(targeted_score.to_sym))}
                elsif self.read_attribute(targeted_score.to_sym).nil?
                  system_messages_temp << {message: t('models.concerns.auditable.scheme_mix_criterion.targeted_score.unset_html', score_label: self.scheme_criterion.read_attribute(SchemeCriterion::LABEL_ATTRIBUTES[index].to_sym) || '', criterion: self.name)}
                else
                  system_messages_temp << {message: t('models.concerns.auditable.scheme_mix_criterion.targeted_score.update_html', score_label: self.scheme_criterion.read_attribute(SchemeCriterion::LABEL_ATTRIBUTES[index].to_sym) || '', criterion: self.name, old_score: self.send("#{targeted_score}_before_last_save"), new_score: self.read_attribute(targeted_score.to_sym))}
                end
              end
            end
            SchemeMixCriterion::SUBMITTED_SCORE_ATTRIBUTES.each_with_index do |submitted_score, index|
              if self.send("saved_change_to_#{submitted_score}?")
                if self.send("#{submitted_score}_before_last_save").nil?
                  system_messages_temp << {message: t('models.concerns.auditable.scheme_mix_criterion.submitted_score.set_html', score_label: self.scheme_criterion.read_attribute(SchemeCriterion::LABEL_ATTRIBUTES[index].to_sym) || '', criterion: self.name, score: self.read_attribute(submitted_score.to_sym))}
                elsif self.read_attribute(submitted_score.to_sym).nil?
                  system_messages_temp << {message: t('models.concerns.auditable.scheme_mix_criterion.submitted_score.unset_html', score_label: self.scheme_criterion.read_attribute(SchemeCriterion::LABEL_ATTRIBUTES[index].to_sym) || '', criterion: self.name)}
                else
                  system_messages_temp << {message: t('models.concerns.auditable.scheme_mix_criterion.submitted_score.update_html', score_label: self.scheme_criterion.read_attribute(SchemeCriterion::LABEL_ATTRIBUTES[index].to_sym) || '', criterion: self.name, old_score: self.send("#{submitted_score}_before_last_save"), new_score: self.read_attribute(submitted_score.to_sym))}
                end
              end
            end
            SchemeMixCriterion::ACHIEVED_SCORE_ATTRIBUTES.each_with_index do |achieved_score, index|
              if self.send("saved_change_to_#{achieved_score}?")
                if self.send("#{achieved_score}_before_last_save").nil?
                  system_messages_temp << {message: t('models.concerns.auditable.scheme_mix_criterion.achieved_score.set_html', score_label: self.scheme_criterion.read_attribute(SchemeCriterion::LABEL_ATTRIBUTES[index].to_sym) || '', criterion: self.name, score: self.read_attribute(achieved_score.to_sym))}
                elsif self.read_attribute(achieved_score.to_sym).nil?
                  system_messages_temp << {message: t('models.concerns.auditable.scheme_mix_criterion.achieved_score.unset_html', score_label: self.scheme_criterion.read_attribute(SchemeCriterion::LABEL_ATTRIBUTES[index].to_sym) || '', criterion: self.name)}
                else
                  system_messages_temp << {message: t('models.concerns.auditable.scheme_mix_criterion.achieved_score.update_html', score_label: self.scheme_criterion.read_attribute(SchemeCriterion::LABEL_ATTRIBUTES[index].to_sym) || '', criterion: self.name, old_score: self.send("#{achieved_score}_before_last_save"), new_score: self.read_attribute(achieved_score.to_sym))}
                end
              end
            end
            SchemeMixCriterion::INCENTIVE_SCORED_ATTRIBUTES.each_with_index do |incentive_scored, index|
              if self.send("saved_change_to_#{incentive_scored}?")
                if self.send("#{incentive_scored}_before_last_save").nil?
                  system_messages_temp << {message: t('models.concerns.auditable.scheme_mix_criterion.incentive_scored.set_html', score_label: self.scheme_criterion.read_attribute(SchemeCriterion::LABEL_ATTRIBUTES[index].to_sym) || '', criterion: self.name, incentive_scored: self.read_attribute(incentive_scored.to_sym))}
                elsif self.read_attribute(incentive_scored.to_sym).nil?
                  system_messages_temp << {message: t('models.concerns.auditable.scheme_mix_criterion.incentive_scored.unset_html', score_label: self.scheme_criterion.read_attribute(SchemeCriterion::LABEL_ATTRIBUTES[index].to_sym) || '', criterion: self.name)}
                else
                  system_messages_temp << {message: t('models.concerns.auditable.scheme_mix_criterion.incentive_scored.update_html', score_label: self.scheme_criterion.read_attribute(SchemeCriterion::LABEL_ATTRIBUTES[index].to_sym) || '', criterion: self.name, old_incentive_scored: self.send("#{incentive_scored}_before_last_save"), new_incentive_scored: self.read_attribute(incentive_scored.to_sym))}
                end
              end
            end
          end
          # If the scheme mix criterion inherits from a criterion in the main scheme mix, notify the user that the changes were automated.
          if self.main_scheme_mix_criterion_id.present?
            # append a string to each message
            system_messages_temp = system_messages_temp.map do |item|
              item[:message] += ' '
              item[:message] += t('models.concerns.auditable.scheme_mix_criterion.main.update_html', main_criterion: self.main_scheme_mix_criterion.full_name, main_scheme: self.scheme_mix.certification_path.main_scheme_mix.name)
              item
            end
          end
          system_messages = system_messages + system_messages_temp
        when SchemeMixCriteriaDocument.name.demodulize
          project = self.scheme_mix_criterion.scheme_mix.certification_path.project
          certification_path = self.scheme_mix_criterion.scheme_mix.certification_path
          if (action == AUDIT_LOG_CREATE)
            system_messages << {message: t('models.concerns.auditable.scheme_mix_criteria_document.status.create_html', document: self.name, criterion: self.scheme_mix_criterion.name)}
          elsif (action == AUDIT_LOG_UPDATE)
            if self.saved_change_to_status?
              system_messages << {message: t('models.concerns.auditable.scheme_mix_criteria_document.status.update_html', document: self.name, criterion: self.scheme_mix_criterion.name, old_status: self.status_before_last_save.humanize, new_status: self.status.humanize)}
            end
          end
        when RequirementDatum.name.demodulize
          if ((action == AUDIT_LOG_UPDATE) || (action == AUDIT_LOG_TOUCH))
            project = self.scheme_mix_criteria.take.scheme_mix.certification_path.project
            certification_path = self.scheme_mix_criteria.take.scheme_mix.certification_path
          end
          if (action == AUDIT_LOG_UPDATE)
            if self.saved_change_to_status?
              system_messages << {message: t('models.concerns.auditable.requirement_datum.status.update_html', requirement: self.name, old_status: self.status_before_last_save.humanize, new_status: self.status.humanize)}
            end
            if self.saved_change_to_user_id? || self.saved_change_to_due_date?
              if self.user_id.blank?
                system_messages << {message: t('models.concerns.auditable.requirement_datum.user.unassigned_html', requirement: self.name)}
              elsif self.due_date?
                system_messages << {message: t('models.concerns.auditable.requirement_datum.user.assigned_for_submittal_due_html', requirement: self.name, user: self.user.full_name, due_date: l(self.due_date, format: :short))}
              else
                system_messages << {message: t('models.concerns.auditable.requirement_datum.user.assigned_for_submittal_html', requirement: self.name, user: self.user.full_name)}
              end
            end
          end
        when Requirement.name.demodulize
          if (action == AUDIT_LOG_UPDATE)
            system_messages << {message: t('models.concerns.auditable.requirement.name.update_html', old_name: self.name_before_last_save, new_name: self.name)}
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
        when SchemeCriterion.name.demodulize
          if (action == AUDIT_LOG_UPDATE)
            if self.saved_change_to_name?
              system_messages << {message: t('models.concerns.auditable.scheme_criterion.name.update_html', old_name: self.name_before_last_save, new_name: self.name)}
            else
              SchemeCriterion::SCORE_ATTRIBUTES.each_with_index do |scores, index|
                if self.send("saved_change_to_#{SchemeCriterion::WEIGHT_ATTRIBUTES[index]}?")
                  system_messages << {message: t('models.concerns.auditable.scheme_criterion.weight.update_html', score_label: self.read_attribute(SchemeCriterion::LABEL_ATTRIBUTES[index].to_sym) || '', old_weight: self.send("#{SchemeCriterion::WEIGHT_ATTRIBUTES[index]}_before_last_save"), new_weight: self.read_attribute(SchemeCriterion::WEIGHT_ATTRIBUTES[index].to_sym))}
                elsif self.send("saved_change_to_#{scores}?")
                  system_messages << {message: t('models.concerns.auditable.scheme_criterion.scores.update_html', score_label: self.read_attribute(SchemeCriterion::LABEL_ATTRIBUTES[index].to_sym) || '', old_scores: self.send("#{scores}_before_last_save").to_s, new_scores: self.read_attribute(scores.to_sym).to_s)}
                elsif self.send("saved_change_to_#{SchemeCriterion::INCENTIVE_MINUS_1_ATTRIBUTES[index]}?")
                  system_messages << {message: t('models.concerns.auditable.scheme_criterion.incentive_weight.update_html', score_label: self.read_attribute(SchemeCriterion::LABEL_ATTRIBUTES[index].to_sym) || '', old_incentive: self.send("#{SchemeCriterion::INCENTIVE_MINUS_1_ATTRIBUTES[index]}_before_last_save"), new_incentive: self.read_attribute(SchemeCriterion::INCENTIVE_MINUS_1_ATTRIBUTES[index].to_sym))}
                elsif self.send("saved_change_to_#{SchemeCriterion::INCENTIVE_0_ATTRIBUTES[index]}?")
                  system_messages << {message: t('models.concerns.auditable.scheme_criterion.incentive_weight.update_html', score_label: self.read_attribute(SchemeCriterion::LABEL_ATTRIBUTES[index].to_sym) || '', old_incentive: self.send("#{SchemeCriterion::INCENTIVE_0_ATTRIBUTES[index]}_before_last_save"), new_incentive: self.read_attribute(SchemeCriterion::INCENTIVE_0_ATTRIBUTES[index].to_sym))}
                elsif self.send("saved_change_to_#{SchemeCriterion::INCENTIVE_1_ATTRIBUTES[index]}?")
                  system_messages << {message: t('models.concerns.auditable.scheme_criterion.incentive_weight.update_html', score_label: self.read_attribute(SchemeCriterion::LABEL_ATTRIBUTES[index].to_sym) || '', old_incentive: self.send("#{SchemeCriterion::INCENTIVE_1_ATTRIBUTES[index]}_before_last_save"), new_incentive: self.read_attribute(SchemeCriterion::INCENTIVE_1_ATTRIBUTES[index].to_sym))}
                elsif self.send("saved_change_to_#{SchemeCriterion::INCENTIVE_2_ATTRIBUTES[index]}?")
                  system_messages << {message: t('models.concerns.auditable.scheme_criterion.incentive_weight.update_html', score_label: self.read_attribute(SchemeCriterion::LABEL_ATTRIBUTES[index].to_sym) || '', old_incentive: self.send("#{SchemeCriterion::INCENTIVE_2_ATTRIBUTES[index]}_before_last_save"), new_incentive: self.read_attribute(SchemeCriterion::INCENTIVE_2_ATTRIBUTES[index].to_sym))}
                elsif self.send("saved_change_to_#{SchemeCriterion::INCENTIVE_3_ATTRIBUTES[index]}?")
                  system_messages << {message: t('models.concerns.auditable.scheme_criterion.incentive_weight.update_html', score_label: self.read_attribute(SchemeCriterion::LABEL_ATTRIBUTES[index].to_sym) || '', old_incentive: self.send("#{SchemeCriterion::INCENTIVE_3_ATTRIBUTES[index]}_before_last_save"), new_incentive: self.read_attribute(SchemeCriterion::INCENTIVE_3_ATTRIBUTES[index].to_sym))}
                end
              end
            end
          end
        when SchemeCategory.name.demodulize
          if (action == AUDIT_LOG_UPDATE)
            if self.saved_change_to_name?
              system_messages << {message: t('models.concerns.auditable.scheme_category.name.update_html', old_name: self.name_before_last_save, new_name: self.name)}
            elsif self.saved_change_to_display_weight?
              system_messages << {message: t('models.concerns.auditable.scheme_category.display_weight.update_html', new_display_weight: self.display_weight)}
            end
          end
        when Scheme.name.demodulize
          if (action == AUDIT_LOG_UPDATE)
            system_messages << {message: t('models.concerns.auditable.scheme.name.update_html', old_name: self.name_before_last_save, new_name: self.name)}
          end
        when CgpCertificationPathDocument.name.demodulize
          certification_path = self.certification_path
          project = certification_path.project
          if (action == AUDIT_LOG_CREATE)
            force_visibility_public = true
            system_messages << {message: t('models.concerns.auditable.certification_path_document.status.create_html', document: self.name)}
          end
        when CertifierCertificationPathDocument.name.demodulize
          certification_path = self.certification_path
          project = certification_path.project
          if (action == AUDIT_LOG_CREATE)
            force_visibility_public = true
            system_messages << {message: t('models.concerns.auditable.certification_path_document.status.create_html', document: self.name)}
          end
      end

      # Format the user comment
      if self.audit_log_user_comment.present?
        user_comment = self.audit_log_user_comment
      else
        user_comment = nil
      end

      # Format the attachment
      if self.audit_log_attachment_file.present?
        attachment_file = self.audit_log_attachment_file
      else
        attachment_file = nil
      end

      # Determine visibility
      if force_visibility_public
        visibility = AuditLogVisibility::PUBLIC
      else
        projects_user = ProjectsUser.for_project(project).for_user(User.current).first
        if projects_user.nil?
          if self.audit_log_visibility.present?
            visibility = self.audit_log_visibility.to_i
          else
            visibility = AuditLogVisibility::INTERNAL
          end
        elsif projects_user.gsas_trust_team?
          if projects_user.certification_manager? && self.audit_log_visibility.present?
            visibility = self.audit_log_visibility.to_i
          else
            visibility = AuditLogVisibility::INTERNAL
          end
        else
          visibility = AuditLogVisibility::PUBLIC
        end
      end

      # Create the audit log record(s)
      if system_messages.present?
        system_messages.each do |system_message|
          AuditLog.create!(
              system_message: system_message[:message],
              user_comment: user_comment,
              attachment_file: attachment_file,
              old_status: system_message.has_key?(:old_status) ? system_message[:old_status] : nil,
              new_status: system_message.has_key?(:new_status) ? system_message[:new_status] : nil,
              user: User.current,
              auditable: auditable,
              certification_path: certification_path,
              project: project,
              audit_log_visibility_id: visibility)
        end
      elsif (user_comment.present? || attachment_file.present?)
        audit_log = AuditLog.new(
            user_comment: user_comment,
            attachment_file: attachment_file,
            user: User.current,
            auditable: auditable,
            certification_path: certification_path,
            project: project,
            audit_log_visibility_id: visibility)
        self.audit_log_errors = audit_log.errors unless audit_log.save
      end
    rescue NoMethodError => e
      Rails.logger.error "Error when creating an audit log for #{self.class.name} ##{self.id}: #{e.to_s}"
      Rails.logger.error e.backtrace.join("\n")
    end
  end
end
