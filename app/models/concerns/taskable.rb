module Taskable
  extend ActiveSupport::Concern

  SYS_ADMIN_ASSIGN = 1
  SYS_ADMIN_REG_APPROVE = 2
  PROJ_MNGR_ASSIGN = 3
  PROJ_MEM_REQ = 4
  PROJ_MNGR_CRIT_APPROVE = 5
  PROJ_MNGR_SUB_APPROVE = 6
  CERT_MNGR_ASSIGN = 7
  CERT_MNGR_SCREEN = 8
  CERT_MNGR_REVIEW = 9
  PROJ_MNGR_PROC_SCREENING = 10
  PROJ_MNGR_REVIEW = 11
  CERT_MEM_VERIFY = 16
  CERT_MNGR_VERIFICATION_APPROVE = 17
  PROJ_MNGR_PROC_VERIFICATION = 18
  SYS_ADMIN_APPEAL_APPROVE = 19
  PROJ_MNGR_PROC_VERIFICATION_APPEAL = 24
  GSAS_TRUST_MNGR_APPROVE = 25
  GSAS_TRUST_TOP_MNGR_APPROVE = 26
  PROJ_MNGR_DOWNLOAD = 28
  PROJ_MNGR_DOC_APPROVE = 29
  PROJ_MNGR_APPLY = 30
  PROJ_MNGR_ASSIGN_AFTER_APPEAL = 31
  PROJ_MNGR_GEN = 32
  SYS_ADMIN_DURATION = 33
  PROJ_MNGR_OVERDUE = 34
  CERT_MNGR_OVERDUE = 35
  CERT_MNGR_ASSIGN_AFTER_APPEAL = 36
  SYS_ADMIN_SELECT_MAIN_SCHEME = 37

  included do
    has_many :tasks, as: :taskable, dependent: :destroy

    after_create :after_create
    after_update :after_update
    before_destroy :before_destroy
    after_destroy :after_destroy
  end

  private

  def after_create
    case self.class.name
      when CertificationPath.name.demodulize
        handle_created_certification_path
      when Project.name.demodulize
        handle_created_project
      when ProjectsUser.name.demodulize
        handle_created_projects_user
      when SchemeMixCriteriaDocument.name.demodulize
        handle_created_scheme_mix_criteria_document
    end
  end

  def after_update
    case self.class.name
      when CertificationPath.name.demodulize
        handle_updated_certification_path
      when Project.name.demodulize
        handle_updated_project
      when ProjectsUser.name.demodulize
        handle_updated_projects_user
      when RequirementDatum.name.demodulize
        handle_updated_requirement_datum
      when SchemeMixCriterion.name.demodulize
        handle_updated_scheme_mix_criterion
      when SchemeMixCriteriaDocument.name.demodulize
        handle_updated_scheme_mix_criteria_document
    end
  end

  def before_destroy
    case self.class.name
      when ProjectsUser.name.demodulize
        Task.delete_all(user: self.user)
      when SchemeMixCriteriaDocument.name.demodulize
        if self.scheme_mix_criterion.scheme_mix_criteria_documents.where(status: SchemeMixCriteriaDocument.statuses[:awaiting_approval]).count.zero?
          Task.delete_all(taskable: self.scheme_mix_criterion, task_description_id: PROJ_MNGR_DOC_APPROVE)
        end
    end
  end

  def after_destroy
    case self.class.name
      when ProjectsUser.name.demodulize
        handle_destroyed_projects_user
    end
  end

  def handle_created_project
    # Create a project manager task to apply for a certificate
    Task.create(taskable: self, task_description_id: PROJ_MNGR_APPLY, project_role: ProjectsUser.roles[:cgp_project_manager], project: self)
    if self.location_plan_file.blank? || self.site_plan_file.blank? || self.design_brief_file.blank? || self.project_narrative_file.blank?
      # Create a project manager task to provide the 'general submittal' documents
      Task.create(taskable: self, task_description_id: PROJ_MNGR_GEN, project_role: ProjectsUser.roles[:cgp_project_manager], project: self)
    else
      DigestMailer.project_registered_email(self).deliver_now
    end
  end

  def handle_created_projects_user
    case ProjectsUser.roles[self.role]
      # A certifier manager is assigned to project
      when ProjectsUser.roles[:certification_manager]
        # Destroy all system admin tasks to assign a certifier manager for this project
        Task.delete_all(taskable: self.project, task_description_id: SYS_ADMIN_ASSIGN)
    end
  end

  def handle_created_certification_path
    unless self.project.certification_manager_assigned?
      # Create system admin task to assign a certifier manager
      Task.create(taskable: self.project,
                 task_description_id: SYS_ADMIN_ASSIGN,
                 application_role: User.roles[:gsas_trust_admin],
                 project: self.project)
    end
    if (self.mixed? && (self.main_scheme_mix_selected? == false))
      # Create system admin task to select a main scheme
      Task.create(taskable: self,
                  task_description_id: SYS_ADMIN_SELECT_MAIN_SCHEME,
                  application_role: User.roles[:gsas_trust_admin],
                  project: self.project,
                  certification_path: self)
    end
    # Create system admin task to advance the certification path status
    Task.create(taskable: self,
               task_description_id: SYS_ADMIN_REG_APPROVE,
               application_role: User.roles[:gsas_trust_admin],
               project: self.project,
               certification_path: self)
    # Destroy project manager tasks to apply for a certification path
    Task.delete_all(taskable: self.project, task_description_id: PROJ_MNGR_APPLY)
  end

  def handle_created_scheme_mix_criteria_document
    # Create project manager task to approve/reject document
    if Task.find_by(taskable: self.scheme_mix_criterion, task_description_id: PROJ_MNGR_DOC_APPROVE).nil?
      Task.create(taskable: self.scheme_mix_criterion,
                  task_description_id: PROJ_MNGR_DOC_APPROVE,
                  project_role: ProjectsUser.roles[:cgp_project_manager],
                  project: self.scheme_mix_criterion.scheme_mix.certification_path.project,
                  certification_path: self.scheme_mix_criterion.scheme_mix.certification_path)
    end
  end

  def handle_updated_project
    if self.location_plan_file_changed? || self.site_plan_file_changed? || self.design_brief_file_changed? || self.project_narrative_file_changed?
      if self.location_plan_file.blank? || self.site_plan_file.blank? || self.design_brief_file.blank? || self.project_narrative_file.blank?
        # Create a project manager task to provide the 'general submittal' documents if it not already exists
        unless self.location_plan_file_was.blank? || self.site_plan_file_was.blank? || self.design_brief_file_was.blank? || self.project_narrative_file_was.blank?
          # Create a project manager task to provide the 'general submittal' documents
          Task.create(taskable: self, task_description_id: PROJ_MNGR_GEN, project_role: ProjectsUser.roles[:cgp_project_manager], project: self)
        end
      else
        Task.delete_all(taskable: self, task_description_id: PROJ_MNGR_GEN)
        DigestMailer.project_registered_email(self).deliver_now
      end
    end
  end

  def handle_updated_projects_user
    if self.role_changed?
      lost_role(self.role_was)
      case ProjectsUser.roles[self.role]
        # when ProjectsUser.roles[:project_team_member]
        # when ProjectsUser.roles[:certifier]
        # project user role is changed to certifier manager
        when ProjectsUser.roles[:certification_manager]
          # Destroy all system admin tasks to assign a certifier manager for this project
          Task.delete_all(taskable: self.project, task_description_id: SYS_ADMIN_ASSIGN)
      end
    end
  end

  def handle_updated_certification_path
    handle_certification_status_changed
    handle_main_scheme_mix_selected_changed
  end

  def handle_certification_status_changed
    if self.certification_path_status_id_changed?
      case self.certification_path_status_id
        when CertificationPathStatus::ACTIVATING
          #
        when CertificationPathStatus::SUBMITTING
          if self.requirement_data.unassigned.required.count.nonzero?
            # Create project manager task to assign project team members to requirements
            Task.create(taskable: self,
                       task_description_id: PROJ_MNGR_ASSIGN,
                       project_role: ProjectsUser.roles[:cgp_project_manager],
                       project: self.project,
                       certification_path: self)
          end
          # Destroy system admin tasks to advance status
          Task.delete_all(taskable: self, task_description_id: SYS_ADMIN_REG_APPROVE)
          DigestMailer.certification_activated_email(self).deliver_now
        when CertificationPathStatus::SCREENING
          # ASSUMING CERTIFIER MANAGER IS RESPONSIBLE FOR SCREENING !
          # ---------------------------------------------------------
          # Create certifier manager task to screen certification path
          Task.create(taskable: self,
                     task_description_id: CERT_MNGR_SCREEN,
                     project_role: ProjectsUser.roles[:certification_manager],
                     project: self.project,
                     certification_path: self)
          # Destroy project manager tasks to advance status
          Task.delete_all(taskable: self, task_description_id: PROJ_MNGR_SUB_APPROVE)
        when CertificationPathStatus::SUBMITTING_AFTER_SCREENING
          # Create project manager task to process screening comments
          Task.create(taskable: self,
                     task_description_id: PROJ_MNGR_PROC_SCREENING,
                     project_role: ProjectsUser.roles[:cgp_project_manager],
                     project: self.project,
                     certification_path: self)
          # Destroy certifier manager tasks to screen certification path
          Task.delete_all(taskable: self, task_description_id: CERT_MNGR_SCREEN)
        when CertificationPathStatus::VERIFYING
          self.scheme_mix_criteria.submitted.where.not(certifier: nil).each do |scheme_mix_criterion|
            # Create certifier team member task to verify the criterion
            Task.create(taskable: scheme_mix_criterion,
                        task_description_id: CERT_MEM_VERIFY,
                        user: scheme_mix_criterion.certifier,
                        project: self.project,
                        certification_path: self)
          end
          # IF PCR IS SKIPPED
          # Destroy project manager tasks to process screening comments
          Task.delete_all(taskable: self, task_description_id: PROJ_MNGR_PROC_SCREENING)
        when CertificationPathStatus::ACKNOWLEDGING
          # Create project manager task to process verification comments
          Task.create(taskable: self,
                     task_description_id: PROJ_MNGR_PROC_VERIFICATION,
                     project_role: ProjectsUser.roles[:cgp_project_manager],
                     project: self.project,
                     certification_path: self)
          # Destroy certifier manager tasks to advance status
          Task.delete_all(taskable: self, task_description_id: CERT_MNGR_VERIFICATION_APPROVE)
        when CertificationPathStatus::PROCESSING_APPEAL_PAYMENT
          # Create system admin task to check appeal payment
          Task.create(taskable: self,
                     task_description_id: SYS_ADMIN_APPEAL_APPROVE,
                     application_role: User.roles[:gsas_trust_admin],
                     project: self.project,
                     certification_path: self)
          # Destroy project manager tasks to process verification comments
          Task.delete_all(taskable: self, task_description_id: PROJ_MNGR_PROC_VERIFICATION)
        when CertificationPathStatus::SUBMITTING_AFTER_APPEAL
          # Create project manager task to assign project team members to requirements
          if self.requirement_data.unassigned.required.count.nonzero?
            if Task.find_by(taskable: self, task_description_id: PROJ_MNGR_ASSIGN_AFTER_APPEAL).nil?
              Task.create(taskable: self,
                         task_description_id: PROJ_MNGR_ASSIGN_AFTER_APPEAL,
                         project_role: ProjectsUser.roles[:cgp_project_manager],
                         project: self.project,
                         certification_path: self)
            end
          end
          # Destroy system admin tasks to check appeal payment
          Task.delete_all(taskable: self, task_description_id: SYS_ADMIN_APPEAL_APPROVE)
          DigestMailer.criteria_appealed_email(self).deliver_now
        when CertificationPathStatus::VERIFYING_AFTER_APPEAL
          # Destroy project manager tasks to advance certification path status
          Task.delete_all(taskable: self, task_description_id: PROJ_MNGR_SUB_APPROVE)
        when CertificationPathStatus::ACKNOWLEDGING_AFTER_APPEAL
          # Create project manager task to process verification comments
          Task.create(taskable: self,
                     task_description_id: PROJ_MNGR_PROC_VERIFICATION_APPEAL,
                     project_role: ProjectsUser.roles[:cgp_project_manager],
                     project: self.project,
                     certification_path: self)
          # Destroy certifier manager tasks to advance status
          Task.delete_all(taskable: self, task_description_id: CERT_MNGR_VERIFICATION_APPROVE)
        when CertificationPathStatus::APPROVING_BY_MANAGEMENT
          # Create GORD manager task to quick check and approve
          Task.create(taskable: self,
                     task_description_id: GSAS_TRUST_MNGR_APPROVE,
                     application_role: User.roles[:gsas_trust_manager],
                     project: self.project,
                     certification_path: self)
          # Destroy project manager tasks to process verification comments
          Task.delete_all(taskable: self, task_description_id: PROJ_MNGR_PROC_VERIFICATION_APPEAL)
          # IF APPEAL IS SKIPPED
          # Destroy project manager tasks to process verification comments
          Task.delete_all(taskable: self, task_description_id: PROJ_MNGR_PROC_VERIFICATION)
        when CertificationPathStatus::APPROVING_BY_TOP_MANAGEMENT
          # Create GORD top manager task to approve
          Task.create(taskable: self,
                     task_description_id: GSAS_TRUST_TOP_MNGR_APPROVE,
                     application_role: User.roles[:gsas_trust_top_manager],
                     project: self.project,
                     certification_path: self)
          # Destroy GORD manager tasks to approve
          Task.delete_all(taskable: self, task_description_id: GSAS_TRUST_MNGR_APPROVE)
        when CertificationPathStatus::CERTIFIED
          # Destroy GORD top manager tasks to approve
          Task.delete_all(taskable: self, task_description_id: GSAS_TRUST_TOP_MNGR_APPROVE)
        when CertificationPathStatus::NOT_CERTIFIED
          # Destroy all certification path tasks
          Task.delete_all(taskable: self)
      end
    end
  end

  def handle_main_scheme_mix_selected_changed
    if self.main_scheme_mix_selected_changed?
      if self.main_scheme_mix_selected?
        Task.delete_all(taskable: self, task_description_id: SYS_ADMIN_SELECT_MAIN_SCHEME)
      end
    end
  end

  def handle_updated_scheme_mix_criterion
    handle_criterion_status_changed
    handle_criterion_assignment_changed
    handle_criterion_due_date_changed
    handle_criterion_in_review_changed
  end

  def handle_criterion_status_changed
    if self.status_changed?
      case SchemeMixCriterion.statuses[self.status]
        when SchemeMixCriterion.statuses[:submitted], SchemeMixCriterion.statuses[:submitted_after_appeal]
          Task.delete_all(taskable: self, task_description_id: PROJ_MNGR_REVIEW)
          # Check if certification with status 'submitted' has no linked criteria in status 'submitting'
          if CertificationPath.joins(:scheme_mixes)
                     .where(id: self.scheme_mix.certification_path.id, certification_path_status_id: [CertificationPathStatus::SUBMITTING, CertificationPathStatus::SUBMITTING_AFTER_APPEAL])
                     .where.not('exists(select smc.id from scheme_mix_criteria smc where smc.scheme_mix_id = scheme_mixes.id and smc.status in (?))', [SchemeMixCriterion.statuses[:submitting],SchemeMixCriterion.statuses[:submitting_after_appeal]])
                     .count.nonzero?
            # Create project manager task to advance certification path status
            Task.create(taskable: self.scheme_mix.certification_path,
                       task_description_id: PROJ_MNGR_SUB_APPROVE,
                       project_role: ProjectsUser.roles[:cgp_project_manager],
                       project: self.scheme_mix.certification_path.project,
                       certification_path: self.scheme_mix.certification_path)
          end
          # Destroy project manager tasks to set criterion status to 'submitted'
          Task.delete_all(taskable: self, task_description_id: PROJ_MNGR_CRIT_APPROVE)
        when SchemeMixCriterion.statuses[:verifying], SchemeMixCriterion.statuses[:verifying_after_appeal]
          if !self.certifier_id_changed?
            if self.certifier_id.nil?
              # Create certifier manager task to assign certifier to the criterion
              if self.verifying?
                if Task.find_by(taskable: self.scheme_mix.certification_path, task_description_id: CERT_MNGR_ASSIGN).nil?
                  Task.create(taskable: self.scheme_mix.certification_path,
                             task_description_id: CERT_MNGR_ASSIGN,
                             project_role: ProjectsUser.roles[:certification_manager],
                             project: self.scheme_mix.certification_path.project,
                             certification_path: self.scheme_mix.certification_path)
                end
              elsif self.verifying_after_appeal?
                if Task.find_by(taskable: self.scheme_mix.certification_path, task_description_id: CERT_MNGR_ASSIGN_AFTER_APPEAL).nil?
                  Task.create(taskable: self.scheme_mix.certification_path,
                                               task_description_id: CERT_MNGR_ASSIGN_AFTER_APPEAL,
                                               project_role: ProjectsUser.roles[:certification_manager],
                                               project: self.scheme_mix.certification_path.project,
                                               certification_path: self.scheme_mix.certification_path)
                end
              end
            else
              # Create certifier team member task to screen the criterion
              Task.create(taskable: self,
                          task_description_id: CERT_MEM_VERIFY,
                          user: self.certifier,
                          project: self.scheme_mix.certification_path.project,
                          certification_path: self.scheme_mix.certification_path)
            end
          end
        when SchemeMixCriterion.statuses[:score_awarded],
            SchemeMixCriterion.statuses[:score_downgraded],
            SchemeMixCriterion.statuses[:score_upgraded],
            SchemeMixCriterion.statuses[:score_minimal],
            SchemeMixCriterion.statuses[:score_awarded_after_appeal],
            SchemeMixCriterion.statuses[:score_downgraded_after_appeal],
            SchemeMixCriterion.statuses[:score_upgraded_after_appeal],
            SchemeMixCriterion.statuses[:score_minimal_after_appeal]
          # Check if certification with status 'verifying' has no linked criteria in status 'verifying'
          if CertificationPath.joins(:scheme_mixes)
                     .where(id: self.scheme_mix.certification_path.id, certification_path_status_id: [CertificationPathStatus::VERIFYING, CertificationPathStatus::VERIFYING_AFTER_APPEAL])
                     .where.not('exists(select smc.id from scheme_mix_criteria smc where smc.scheme_mix_id = scheme_mixes.id and smc.status in (?))', [SchemeMixCriterion.statuses[:verifying],SchemeMixCriterion.statuses[:verifying_after_appeal]])
                     .count.nonzero?
            # Create certifier manager task to advance certification path status
            Task.create(taskable: self.scheme_mix.certification_path,
                       task_description_id: CERT_MNGR_VERIFICATION_APPROVE,
                       project_role: ProjectsUser.roles[:certification_manager],
                       project: self.scheme_mix.certification_path.project,
                       certification_path: self.scheme_mix.certification_path)
          end
          # Destroy certifier member tasks to verify criterion
          Task.delete_all(taskable: self, task_description_id: CERT_MEM_VERIFY)
          # Destroy certifier manager tasks to assign certifier team members to the criterion
          if self.scheme_mix.certification_path.scheme_mix_criteria.unassigned.where(status: [SchemeMixCriterion.statuses[:verifying], SchemeMixCriterion.statuses[:verifying_after_appeal]]).count.zero?
            Task.delete_all(taskable: self.scheme_mix.certification_path, task_description_id: [CERT_MNGR_ASSIGN, CERT_MNGR_ASSIGN_AFTER_APPEAL])
          end
          if !self.due_date.blank? && self.due_date < Date.current
            # Destroy certifier manager tasks to follow up overdue tasks
            Task.delete_all(taskable: self, task_description_id: CERT_MNGR_OVERDUE)
          end
      end
    end
  end

  def handle_criterion_assignment_changed
    if self.certifier_id_changed?
      if self.certifier_id.nil?
        # Create certifier manager task to assign certifier to the criterion
        if self.verifying?
          if Task.find_by(taskable: self.scheme_mix.certification_path, task_description_id: CERT_MNGR_ASSIGN).nil?
            Task.create(taskable: self.scheme_mix.certification_path,
                       task_description_id: CERT_MNGR_ASSIGN,
                       project_role: ProjectsUser.roles[:certification_manager],
                       project: self.scheme_mix.certification_path.project,
                       certification_path: self.scheme_mix.certification_path)
          end
        elsif self.verifying_after_appeal?
          if Task.find_by(taskable: self.scheme_mix.certification_path, task_description_id: CERT_MNGR_ASSIGN_AFTER_APPEAL).nil?
            Task.create(taskable: self.scheme_mix.certification_path,
                       task_description_id: CERT_MNGR_ASSIGN_AFTER_APPEAL,
                       project_role: ProjectsUser.roles[:certification_manager],
                       project: self.scheme_mix.certification_path.project,
                       certification_path: self.scheme_mix.certification_path)
          end
        end
        # Destroy all certifier team member tasks to verify the criterion
        Task.delete_all(taskable: self, task_description_id: CERT_MEM_VERIFY)
      else
        # Destroy all certifier team member tasks to verify the criterion which are assigned to another user
        Task.delete_all(taskable: self, task_description_id: CERT_MEM_VERIFY)
        if [SchemeMixCriterion.statuses[:verifying], SchemeMixCriterion.statuses[:verifying_after_appeal]].include?(SchemeMixCriterion.statuses[self.status])
          # Create certifier team member task to verify the criterion
          Task.create(taskable: self,
                      task_description_id: CERT_MEM_VERIFY,
                      user: self.certifier,
                      project: self.scheme_mix.certification_path.project,
                      certification_path: self.scheme_mix.certification_path)
        end
        # Destroy all certifier manager tasks to assign certifier team member to this criterion
        if self.scheme_mix.certification_path.scheme_mix_criteria.unassigned.where(status: [SchemeMixCriterion.statuses[:verifying], SchemeMixCriterion.statuses[:verifying_afer_appeal]]).count.zero?
          Task.delete_all(taskable: self.scheme_mix.certification_path, task_description_id: [CERT_MNGR_ASSIGN, CERT_MNGR_ASSIGN_AFTER_APPEAL])
        end
      end
    end
  end

  def handle_criterion_due_date_changed
    if self.due_date_changed?
      if (self.due_date_was.present? && (self.due_date_was < Date.current)) && (self.due_date.blank? || (self.due_date > Date.current))
        # Destroy certifier manager tasks to follow up overdue tasks
        Task.delete_all(taskable: self, task_description_id: CERT_MNGR_OVERDUE)
      end
    end
  end

  def handle_criterion_in_review_changed
    if self.in_review_changed?
      if self.in_review?
        Task.delete_all(taskable: self, task_description_id: PROJ_MNGR_REVIEW)
        if Task.find_by(taskable: self, task_description_id: CERT_MNGR_REVIEW).nil?
          # Create certifier manager task to provide a PCR review comment
          Task.create(taskable: self,
                      task_description_id: CERT_MNGR_REVIEW,
                      project_role: ProjectsUser.roles[:certification_manager],
                      project: self.scheme_mix.certification_path.project,
                      certification_path: self.scheme_mix.certification_path)
        end
      else
        Task.delete_all(taskable: self, task_description_id: CERT_MNGR_REVIEW)
        if Task.find_by(taskable: self, task_description_id: PROJ_MNGR_REVIEW).nil?
          Task.create(taskable: self, task_description_id: PROJ_MNGR_REVIEW, project_role: ProjectsUser.roles[:cgp_project_manager], project: self.scheme_mix.certification_path.project, certification_path: self.scheme_mix.certification_path)
        end
      end
    end
  end

  def handle_updated_requirement_datum
    handle_requirement_status_changed
    handle_requirement_assignment_changed
    handle_requirement_due_date_changed
  end

  def handle_requirement_status_changed
    if self.status_changed?
      case RequirementDatum.statuses[self.status]
        when RequirementDatum.statuses[:required]
          if !self.user_id_changed?
            if self.user_id.nil?
              if self.scheme_mix_criteria.first.submitting?
                # Create project manager task to assign a project team member to the requirement
                if Task.find_by(taskable: self.scheme_mix_criteria.first.scheme_mix.certification_path, task_description_id: PROJ_MNGR_ASSIGN).nil?
                  Task.create(taskable: self.scheme_mix_criteria.first.scheme_mix.certification_path,
                             task_description_id: PROJ_MNGR_ASSIGN,
                             project_role: ProjectsUser.roles[:cgp_project_manager],
                             project: self.scheme_mix_criteria.first.scheme_mix.certification_path.project,
                             certification_path: self.scheme_mix_criteria.first.scheme_mix.certification_path)
                end
              elsif self.scheme_mix_criteria.first.submitting_after_appeal?
                # Create project manager task to assign a project team member to the requirement
                if Task.find_by(taskable: self.scheme_mix_criteria.first.scheme_mix.certification_path, task_description_id: PROJ_MNGR_ASSIGN_AFTER_APPEAL).nil?
                  Task.create(taskable: self.scheme_mix_criteria.first.scheme_mix.certification_path,
                             task_description_id: PROJ_MNGR_ASSIGN_AFTER_APPEAL,
                             project_role: ProjectsUser.roles[:cgp_project_manager],
                             project: self.scheme_mix_criteria.first.scheme_mix.certification_path.project,
                             certification_path: self.scheme_mix_criteria.first.scheme_mix.certification_path)
                end
              end
            else
              # Create project team member task to provide the requirement
              if Task.find_by(taskable: self.scheme_mix_criteria.first, task_description_id: PROJ_MEM_REQ, user: self.user).nil?
                Task.create(taskable: self.scheme_mix_criteria.first,
                            task_description_id: PROJ_MEM_REQ,
                            user: self.user,
                            project: self.scheme_mix_criteria.first.scheme_mix.certification_path.project,
                            certification_path: self.scheme_mix_criteria.first.scheme_mix.certification_path)
              end
            end
          end
          # Destroy project manager tasks to set criterion status to complete
          Task.delete_all(taskable: self.scheme_mix_criteria.first,
                          task_description_id: PROJ_MNGR_CRIT_APPROVE,
                          project_role: ProjectsUser.roles[:cgp_project_manager],
                          project: self.scheme_mix_criteria.first.scheme_mix.certification_path.project)
        when RequirementDatum.statuses[:provided], RequirementDatum.statuses[:not_required]
          # Check if criterion with status 'submitting'/'submitting after appeal' has no linked requirements in status 'required'
          if SchemeMixCriterion.joins(:scheme_mix_criteria_requirement_data)
                     .where(id: self.scheme_mix_criteria.first.id, status: [SchemeMixCriterion.statuses[:submitting],SchemeMixCriterion.statuses[:submitting_after_appeal]])
                     .where.not('exists(select rd.id from requirement_data rd inner join scheme_mix_criteria_requirement_data smcrd on smcrd.requirement_datum_id = rd.id where smcrd.scheme_mix_criterion_id = scheme_mix_criteria.id and rd.status = ?)', RequirementDatum.statuses[:required])
                     .count.nonzero?
            # Create project manager task to advance criterion status
            Task.create(taskable: self.scheme_mix_criteria.first,
                        task_description_id: PROJ_MNGR_CRIT_APPROVE,
                        project_role: ProjectsUser.roles[:cgp_project_manager],
                        project: self.scheme_mix_criteria.first.scheme_mix.certification_path.project,
                        certification_path: self.scheme_mix_criteria.first.scheme_mix.certification_path)
          end
          unless self.user_id_changed?
            count = self.scheme_mix_criteria.first.requirement_data.where(status: RequirementDatum.statuses[:required], user: self.user).count
            if !count.nil? && count.zero?
              Task.delete_all(taskable: self.scheme_mix_criteria.first, task_description_id: PROJ_MEM_REQ, user: self.user)
            end
          end
          # Destroy project manager tasks to assign project team members to requirement and project team member tasks to provide the requirement
          if self.scheme_mix_criteria.first.scheme_mix.certification_path.requirement_data.unassigned.where(status: RequirementDatum.statuses[:required]).count.zero?
            Task.delete_all(taskable: self.scheme_mix_criteria.first.scheme_mix.certification_path, task_description_id: [PROJ_MNGR_ASSIGN, PROJ_MNGR_ASSIGN_AFTER_APPEAL])
          end
          if !self.due_date.blank? && self.due_date < Date.current
            # Destroy project manager tasks to follow up overdue tasks
            Task.delete_all(taskable: self, task_description_id: PROJ_MNGR_OVERDUE)
          end
      end
    end
  end

  def handle_requirement_assignment_changed
    if self.user_id_changed?
      if self.user_id.nil?
        if RequirementDatum.statuses[self.status] == RequirementDatum.statuses[:required]
          if self.scheme_mix_criteria.first.submitting?
            # Create project manager task to assign project team member
            if Task.find_by(taskable: self.scheme_mix_criteria.first.scheme_mix.certification_path, task_description_id: PROJ_MNGR_ASSIGN).nil?
              Task.create(taskable: self.scheme_mix_criteria.first.scheme_mix.certification_path,
                         task_description_id: PROJ_MNGR_ASSIGN,
                         project_role: ProjectsUser.roles[:cgp_project_manager],
                         project: self.scheme_mix_criteria.first.scheme_mix.certification_path.project,
                         certification_path: self.scheme_mix_criteria.first.scheme_mix.certification_path)
            end
          elsif self.scheme_mix_criteria.first.submitting_after_appeal?
            # Create project manager task to assign project team member
            if Task.find_by(taskable: self.scheme_mix_criteria.first.scheme_mix.certification_path, task_description_id: PROJ_MNGR_ASSIGN_AFTER_APPEAL).nil?
              Task.create(taskable: self.scheme_mix_criteria.first.scheme_mix.certification_path,
                         task_description_id: PROJ_MNGR_ASSIGN_AFTER_APPEAL,
                         project_role: ProjectsUser.roles[:cgp_project_manager],
                         project: self.scheme_mix_criteria.first.scheme_mix.certification_path.project,
                         certification_path: self.scheme_mix_criteria.first.scheme_mix.certification_path)
            end
          end
        end
        # Destroy project team member tasks to provide the requirement
        if self.scheme_mix_criteria.first.requirement_data.where(status: RequirementDatum.statuses[:required], user_id: self.user_id_was).count.zero?
          Task.delete_all(taskable: self, task_description_id: PROJ_MEM_REQ, user_id: self.user_id_was)
        end
      else
        # Destroy project team member tasks to provide the requirement (which are assigned to another user)
        if self.scheme_mix_criteria.first.requirement_data.where(status: RequirementDatum.statuses[:required], user_id: self.user_id_was).count.zero?
          Task.delete_all(taskable: self, task_description_id: PROJ_MEM_REQ, user_id: self.user_id_was)
        end
        if RequirementDatum.statuses[self.status] == RequirementDatum.statuses[:required]
          if self.scheme_mix_criteria.first.scheme_mix.certification_path.in_submission?
            # Create project team member task to provide the requirement
            if Task.find_by(taskable: self.scheme_mix_criteria.first, task_description_id: PROJ_MEM_REQ, user: self.user).nil?
              Task.create(taskable: self.scheme_mix_criteria.first,
                          task_description_id: PROJ_MEM_REQ,
                          user: self.user,
                          project: self.scheme_mix_criteria.first.scheme_mix.certification_path.project,
                          certification_path: self.scheme_mix_criteria.first.scheme_mix.certification_path)
            end
          end
        end
        # Destroy project manager tasks to assign project team member
        if self.scheme_mix_criteria.first.scheme_mix.certification_path.requirement_data.unassigned.where(status: RequirementDatum.statuses[:required]).count.zero?
          Task.delete_all(taskable: self.scheme_mix_criteria.first.scheme_mix.certification_path, task_description_id: [PROJ_MNGR_ASSIGN, PROJ_MNGR_ASSIGN_AFTER_APPEAL])
        end
      end
    end
  end

  def handle_requirement_due_date_changed
    if self.due_date_changed?
      if (self.due_date_was.present? && (self.due_date_was < Date.current)) && (self.due_date.blank? || (self.due_date > Date.current))
        # Destroy project manager tasks to follow up overdue tasks
        Task.delete_all(taskable: self, task_description_id: PROJ_MNGR_OVERDUE)
      end
    end
  end

  def handle_updated_scheme_mix_criteria_document
    handle_document_status_changed
  end

  def handle_document_status_changed
    if self.status_changed?
      case SchemeMixCriteriaDocument.statuses[self.status]
        when SchemeMixCriteriaDocument.statuses[:awaiting_approval]
          # Create project manager task to approve/reject document
          if Task.find_by(taskable: self.scheme_mix_criterion, task_description_id: PROJ_MNGR_DOC_APPROVE).nil?
            Task.create(taskable: self.scheme_mix_criterion,
                        task_description_id: PROJ_MNGR_DOC_APPROVE,
                        project_role: ProjectsUser.roles[:cgp_project_manager],
                        project: self.scheme_mix_criterion.scheme_mix.certification_path.project,
                        certification_path: self.scheme_mix_criterion.scheme_mix.certification_path)
          end
        when SchemeMixCriteriaDocument.statuses[:approved], SchemeMixCriteriaDocument.statuses[:rejected]
          # Destroy project managers tasks to approve/reject document
          if self.scheme_mix_criterion.scheme_mix_criteria_documents.where(status: SchemeMixCriteriaDocument.statuses[:awaiting_approval]).count.zero?
            Task.delete_all(taskable: self.scheme_mix_criterion, task_description_id: PROJ_MNGR_DOC_APPROVE)
          end
      end
    end
  end

  def handle_destroyed_projects_user
    lost_role(self.role)
  end

  def lost_role(role)
    case ProjectsUser.roles[role]
      # A project team member is unassigned from project
      when ProjectsUser.roles[:project_team_member]
        # Create project manager tasks to assign project member to requirement
        project.certification_paths.with_status(CertificationPathStatus::SUBMITTING).each do |certification_path|
          if Task.find_by(taskable: certification_path, task_description_id: PROJ_MNGR_ASSIGN).nil?
            if certification_path.requirement_data.unassigned.required.count.nonzero?
              Task.create(taskable: certification_path,
                         task_description_id: PROJ_MNGR_ASSIGN,
                         project_role: ProjectsUser.roles[:cgp_project_manager],
                         project: self.project,
                         certification_path: certification_path)
            end
          end
        end
        project.certification_paths.with_status(CertificationPathStatus::SUBMITTING_AFTER_APPEAL).each do |certification_path|
          if Task.find_by(taskable: certification_path, task_description_id: PROJ_MNGR_ASSIGN_AFTER_APPEAL).nil?
            if certification_path.requirement_data.unassigned.required.count.nonzero?
              Task.create(taskable: certification_path,
                         task_description_id: PROJ_MNGR_ASSIGN_AFTER_APPEAL,
                         project_role: ProjectsUser.roles[:cgp_project_manager],
                         project: self.project,
                         certification_path: certification_path)
            end
          end
        end
      # A certifier is unassigned from project
      when ProjectsUser.roles[:certifier]
        # Create certifier manager tasks to assign certifier team members to criteria
        project.certification_paths.with_status(CertificationPathStatus::VERIFYING).each do |certification_path|
          if Task.find_by(taskable: certification_path, task_description_id: CERT_MNGR_ASSIGN).nil?
            if certification_path.scheme_mix_criteria.unassigned.verifying.count.nonzero?
              Task.create(taskable: certification_path,
                         task_description_id: CERT_MNGR_ASSIGN,
                         project_role: ProjectsUser.roles[:certification_manager],
                         project: self.project,
                         certification_path: certification_path)
            end
          end
        end
        project.certification_paths.with_status(CertificationPathStatus::VERIFYING).each do |certification_path|
          if Task.find_by(taskable: certification_path, task_description_id: CERT_MNGR_ASSIGN_AFTER_APPEAL).nil?
            if certification_path.scheme_mix_criteria.unassigned.verifying.count.nonzero?
              Task.create(taskable: certification_path,
                         task_description_id: CERT_MNGR_ASSIGN_AFTER_APPEAL,
                         project_role: ProjectsUser.roles[:certification_manager],
                         project: self.project,
                         certification_path: certification_path)
            end
          end
        end
      # A certifier manager is unassigned from project
      when ProjectsUser.roles[:certification_manager]
        unless self.project.certification_manager_assigned?
          # Create system admin task to assign a certifier manager
          Task.create(taskable: self.project,
                     task_description_id: SYS_ADMIN_ASSIGN,
                     application_role: User.roles[:gsas_trust_admin],
                     project: self.project)
        end
    end
  end

end