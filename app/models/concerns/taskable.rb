module Taskable
  extend ActiveSupport::Concern

  SYS_ADMIN_ASSIGN = 1
  SYS_ADMIN_REG_APPROVE = 2
  PROJ_MNGR_ASSIGN_FOR_SUBMITTAL = 3
  PROJ_MEM_REQ = 4
  PROJ_MNGR_CRIT_APPROVE = 5
  PROJ_MNGR_SUB_APPROVE = 6
  CERT_MNGR_ASSIGN_FOR_VERIFICATION = 7
  CERT_MNGR_ASSIGN_FOR_SCREENING = 8
  CERT_MNGR_REVIEW = 9
  PROJ_MNGR_PROC_SCREENING = 10
  PROJ_MNGR_REVIEW = 11
  CERT_MEM_VERIFY = 16
  CERT_MNGR_VERIFICATION_APPROVE = 17
  PROJ_MNGR_PROC_VERIFICATION = 18
  SYS_ADMIN_APPEAL_APPROVE = 19
  PROJ_MNGR_PROC_VERIFICATION_APPEAL = 24
  GSB_TRUST_MNGR_APPROVE = 25
  GSB_TRUST_TOP_MNGR_APPROVE = 26
  PROJ_MNGR_DOWNLOAD = 28
  PROJ_MNGR_DOC_APPROVE = 29
  PROJ_MNGR_APPLY = 30
  PROJ_MNGR_ASSIGN_FOR_SUBMITTAL_AFTER_APPEAL = 31
  PROJ_MNGR_GEN = 32 # This task is removed
  SYS_ADMIN_DURATION = 33
  PROJ_MNGR_OVERDUE = 34
  CERT_MNGR_OVERDUE = 35
  CERT_MNGR_ASSIGN_FOR_VERIFICATION_AFTER_APPEAL = 36
  SYS_ADMIN_SELECT_MAIN_SCHEME = 37
  CERT_MEM_SCREEN = 38
  CERT_MNGR_SCREENING_APPROVE = 39
  CERT_MEM_REVIEW = 40
  CERT_MNGR_PUBLISH_REVIEW = 41
  PROJ_MNGR_UPLOAD_CMP = 42
  CERT_MNGR_CMP_UPLOADED = 43
  CGP_CERTIFICATION_REPORT_INFORMATION = 44
  DC_CERTIFICATION_REPORT_INFORMATION = 45
  ACTIVATE_USER = 46
  SERVICE_PROVIDER_NAME_CHANGE = 47
  SIGNED_CERTIFICATE_DOWNLOAD = 48


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
      when CgpCertificationPathDocument.name.demodulize
        handle_created_cgp_certification_path_document
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
      when CertificationPathReport.name.demodulize
        handle_updated_certification_path_report
      when User.name.demodulize, ServiceProvider.name.demodulize
        if saved_change_to_confirmed_at? || saved_change_to_username? || saved_change_to_email?
          handle_confirmed_user_account
        end
        if saved_change_to_organization_name?
          handle_change_org_name
        end
        if saved_change_to_active?
          handle_activated_user_account
        end
    end
  end

  def before_destroy
    case self.class.name
      when Project.name.demodulize
        handle_projects_users_tasks
      when CertificationPath.name.demodulize
        Task.where(certification_path: self).delete_all
      when ProjectsUser.name.demodulize
        Task.where(project: self.project, user: self.user).delete_all
      when SchemeMixCriteriaDocument.name.demodulize
        if self.scheme_mix_criterion.scheme_mix_criteria_documents.where(status: SchemeMixCriteriaDocument.statuses[:awaiting_approval]).count.zero?
          Task.where(taskable: self.scheme_mix_criterion, task_description_id: PROJ_MNGR_DOC_APPROVE).delete_all
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
  end

  def handle_created_projects_user
    case ProjectsUser.roles[self.role]
      # A certification manager is assigned to project
      when ProjectsUser.roles[:certification_manager]
        # Destroy all system admin tasks to assign a certification manager for this project
        Task.where(taskable: self.project, task_description_id: SYS_ADMIN_ASSIGN).delete_all
    end
  end

  def handle_created_certification_path
    unless self.certification_manager_assigned?
      # Create system admin task to assign a certification manager
      Task.create(taskable: self.project,
                 task_description_id: SYS_ADMIN_ASSIGN,
                 application_role: User.roles[:gsb_trust_admin],
                 project: self.project)
    end
    if (self.development_type.mixable? && (self.main_scheme_mix_selected? == false))
      # Create system admin task to select a main scheme
      Task.find_or_create_by(taskable: self,
                  task_description_id: SYS_ADMIN_SELECT_MAIN_SCHEME,
                  application_role: User.roles[:gsb_trust_admin],
                  project: self.project,
                  certification_path: self)
    end
    if self.certificate.construction_certificate_stage1?
      # Create CGP project manager task to upload CMP (in case of construction stage 1)
      Task.find_or_create_by(taskable: self,
                  task_description_id: PROJ_MNGR_UPLOAD_CMP,
                  project_role: ProjectsUser.roles[:cgp_project_manager],
                  project: self.project,
                  certification_path: self)
    end
    unless self.certificate.construction_certificate?
      # Create system admin task to advance the certification path status
      Task.find_or_create_by(taskable: self,
                 task_description_id: SYS_ADMIN_REG_APPROVE,
                 application_role: User.roles[:gsb_trust_admin],
                 project: self.project,
                 certification_path: self)
    else
      # Create GORD top manager task to approve
      Task.find_or_create_by(taskable: self,
                  task_description_id: GSB_TRUST_TOP_MNGR_APPROVE,
                  application_role: User.roles[:gsb_trust_top_manager],
                  project: self.project,
                  certification_path: self)
    end
    # Destroy project manager tasks to apply for a certification path
    Task.where(taskable: self.project, task_description_id: PROJ_MNGR_APPLY).delete_all
  end

  def handle_created_scheme_mix_criteria_document
    # Create project manager task to approve/reject document
    if Task.find_by(taskable: self.scheme_mix_criterion, task_description_id: PROJ_MNGR_DOC_APPROVE).nil?
      Task.find_or_create_by(taskable: self.scheme_mix_criterion,
                  task_description_id: PROJ_MNGR_DOC_APPROVE,
                  project_role: ProjectsUser.roles[:cgp_project_manager],
                  project: self.scheme_mix_criterion.scheme_mix.certification_path.project,
                  certification_path: self.scheme_mix_criterion.scheme_mix.certification_path)
    end
  end

  def handle_created_cgp_certification_path_document
    # Destroy CGP project managers upload CMP tasks
    Task.where(taskable: self.certification_path, task_description_id: PROJ_MNGR_UPLOAD_CMP).delete_all
    # Create certification manager task to read the GSB CMP document
    if self.certification_path.certificate.construction_type? && self.certification_path.cgp_certification_path_documents.count == 1
      Task.create(taskable: self.certification_path,
                  task_description_id: CERT_MNGR_CMP_UPLOADED,
                  project_role: ProjectsUser.roles[:certification_manager],
                  project: self.certification_path.project,
                  certification_path: self.certification_path
                  )
    end
  end

  def handle_confirmed_user_account
    # Create task form credentials_admin to activate user profile.
    Task.find_or_create_by(
      taskable: self,
      task_description_id: ACTIVATE_USER,
      application_role: User.roles[:credentials_admin]
    )
  end

  def handle_activated_user_account
    # Delete task of activate user profile.
    Task.where(
      taskable: self,
      task_description_id: ACTIVATE_USER,
      application_role: User.roles[:credentials_admin]
    ).destroy_all if active?
  end

  def handle_change_org_name
    Task.find_or_create_by(
      taskable: self,
      task_description_id: SERVICE_PROVIDER_NAME_CHANGE,
      application_role: User.roles[:credentials_admin]
    )
  end

  def handle_updated_project
  end

  def handle_updated_projects_user
    if self.saved_change_to_role?
      lost_role(self.role_before_last_save)
      case ProjectsUser.roles[self.role]
        # when ProjectsUser.roles[:project_team_member]
        # when ProjectsUser.roles[:certifier]
        # project user role is changed to certification manager
        when ProjectsUser.roles[:certification_manager]
          # Destroy all system admin tasks to assign a certification manager for this project
          Task.where(taskable: self.project, task_description_id: SYS_ADMIN_ASSIGN).delete_all
      end
    end
  end

  def handle_updated_certification_path
    handle_certification_status_changed
    handle_main_scheme_mix_selected_changed
  end

  def handle_certification_status_changed
    if self.saved_change_to_certification_path_status_id?
      case self.certification_path_status_id
        when CertificationPathStatus::ACTIVATING
          #
        when CertificationPathStatus::SUBMITTING
          if self.requirement_data.unassigned.required.count.nonzero?
            # Create project manager task to assign project team members to requirements
            Task.create(taskable: self,
                       task_description_id: PROJ_MNGR_ASSIGN_FOR_SUBMITTAL,
                       project_role: ProjectsUser.roles[:cgp_project_manager],
                       project: self.project,
                       certification_path: self)
          end
          # Destroy system admin tasks to advance status
          Task.where(taskable: self, task_description_id: SYS_ADMIN_REG_APPROVE).delete_all
          # Destroy certifier manager notification that CMP was uploaded
          Task.where(taskable: self, task_description_id: CERT_MNGR_CMP_UPLOADED).delete_all
          DigestMailer.certification_activated_email(self).deliver_now
        when CertificationPathStatus::SCREENING
          # Create certification manager task to assign certifiers to criteria for screening
          Task.find_or_create_by(taskable: self,
                     task_description_id: CERT_MNGR_ASSIGN_FOR_SCREENING,
                     project_role: ProjectsUser.roles[:certification_manager],
                     project: self.project,
                     certification_path: self)
          # Destroy project manager tasks to advance status
          Task.where(taskable: self, task_description_id: PROJ_MNGR_SUB_APPROVE).delete_all
        when CertificationPathStatus::SUBMITTING_AFTER_SCREENING
          # Create project manager task to process screening comments
          Task.find_or_create_by(taskable: self,
                     task_description_id: PROJ_MNGR_PROC_SCREENING,
                     project_role: ProjectsUser.roles[:cgp_project_manager],
                     project: self.project,
                     certification_path: self)
          # Destroy certification manager tasks for assigning people for screening
          Task.where(taskable: self, task_description_id: CERT_MNGR_ASSIGN_FOR_SCREENING).delete_all
          # Destroy certification manager tasks to advance status
          Task.where(taskable: self, task_description_id: CERT_MNGR_SCREENING_APPROVE).delete_all
          # Destroy certifier manager notification that CMP was uploaded
          Task.where(taskable: self, task_description_id: CERT_MNGR_CMP_UPLOADED).delete_all
        when CertificationPathStatus::VERIFYING
          self.scheme_mix_criteria.submitted.where.not(certifier: nil).each do |scheme_mix_criterion|
            # Create certifier team member task to verify the criterion
            Task.find_or_create_by(taskable: scheme_mix_criterion,
                        task_description_id: CERT_MEM_VERIFY,
                        user: scheme_mix_criterion.certifier,
                        project: self.project,
                        certification_path: self)
          end
          # IF PCR IS SKIPPED
          # Destroy project manager tasks to process screening comments
          Task.where(taskable: self, task_description_id: PROJ_MNGR_PROC_SCREENING).delete_all
          # Destroy project manager tasks to follow up overdue tasks
          Task.where(task_description_id: PROJ_MNGR_OVERDUE, certification_path: self).delete_all
          # Destroy project manager tasks to approve documents
          Task.where(task_description_id: PROJ_MNGR_DOC_APPROVE, certification_path: self).delete_all
          # Destroy project manager tasks to process review comments
          Task.where(task_description_id: PROJ_MNGR_REVIEW, certification_path: self).delete_all
          # Destroy tasks to provide requirement documentation
          Task.where(task_description_id: PROJ_MEM_REQ, certification_path: self).delete_all
        when CertificationPathStatus::ACKNOWLEDGING
          # Create project manager task to process verification comments
          Task.find_or_create_by(taskable: self,
                     task_description_id: PROJ_MNGR_PROC_VERIFICATION,
                     project_role: ProjectsUser.roles[:cgp_project_manager],
                     project: self.project,
                     certification_path: self)
          # Destroy certification manager tasks to advance status
          Task.where(taskable: self, task_description_id: CERT_MNGR_VERIFICATION_APPROVE).delete_all
          # Destroy certifier manager notification that CMP was uploaded
          Task.where(taskable: self, task_description_id: CERT_MNGR_CMP_UPLOADED).delete_all
          # Destroy certification manager tasks to follow up overdue tasks
          Task.where(task_description_id: CERT_MNGR_OVERDUE, certification_path: self).delete_all
          # Destroy certification manager tasks to provided PCR review comment
          Task.where(task_description_id: CERT_MNGR_REVIEW, certification_path: self).delete_all
        when CertificationPathStatus::PROCESSING_APPEAL_PAYMENT
          # Create system admin task to check appeal payment
          Task.find_or_create_by(taskable: self,
                     task_description_id: SYS_ADMIN_APPEAL_APPROVE,
                     application_role: User.roles[:gsb_trust_admin],
                     project: self.project,
                     certification_path: self)
          # Destroy project manager tasks to process verification comments
          Task.where(taskable: self, task_description_id: PROJ_MNGR_PROC_VERIFICATION).delete_all
        when CertificationPathStatus::SUBMITTING_AFTER_APPEAL
          # Create project manager task to assign project team members to requirements
          if self.requirement_data.unassigned.required.count.nonzero?
            if Task.find_by(taskable: self, task_description_id: PROJ_MNGR_ASSIGN_FOR_SUBMITTAL_AFTER_APPEAL).nil?
              Task.find_or_create_by(taskable: self,
                         task_description_id: PROJ_MNGR_ASSIGN_FOR_SUBMITTAL_AFTER_APPEAL,
                         project_role: ProjectsUser.roles[:cgp_project_manager],
                         project: self.project,
                         certification_path: self)
            end
          end
          # Destroy system admin tasks to check appeal payment
          Task.where(taskable: self, task_description_id: SYS_ADMIN_APPEAL_APPROVE).delete_all
          # Destroy certifier manager notification that CMP was uploaded
          Task.where(taskable: self, task_description_id: CERT_MNGR_CMP_UPLOADED).delete_all
          DigestMailer.criteria_appealed_email(self).deliver_now
        when CertificationPathStatus::VERIFYING_AFTER_APPEAL
          # Destroy project manager tasks to follow up overdue tasks
          Task.where(task_description_id: PROJ_MNGR_OVERDUE, certification_path: self).delete_all
          # Destroy project manager tasks to advance certification path status
          Task.where(taskable: self, task_description_id: PROJ_MNGR_SUB_APPROVE).delete_all
          # Destroy project manager tasks to approve documents
          Task.where(task_description_id: PROJ_MNGR_DOC_APPROVE, certification_path: self).delete_all
          # Destroy project manager tasks to process review comments
          Task.where(task_description_id: PROJ_MNGR_REVIEW, certification_path: self).delete_all
          # Destroy tasks to provide requirement documentation
          Task.where(task_description_id: PROJ_MEM_REQ, certification_path: self).delete_all
        when CertificationPathStatus::ACKNOWLEDGING_AFTER_APPEAL
          # Create project manager task to process verification comments
          Task.find_or_create_by(taskable: self,
                     task_description_id: PROJ_MNGR_PROC_VERIFICATION_APPEAL,
                     project_role: ProjectsUser.roles[:cgp_project_manager],
                     project: self.project,
                     certification_path: self)
          # Destroy certification manager tasks to advance status
          Task.where(taskable: self, task_description_id: CERT_MNGR_VERIFICATION_APPROVE).delete_all
          # Destroy certifier manager notification that CMP was uploaded
          Task.where(taskable: self, task_description_id: CERT_MNGR_CMP_UPLOADED).delete_all
          # Destroy certification manager tasks to follow up overdue tasks
          Task.where(task_description_id: CERT_MNGR_OVERDUE, certification_path: self).delete_all
          # Destroy certification manager tasks to provided PCR review comment
          Task.where(task_description_id: CERT_MNGR_REVIEW, certification_path: self).delete_all
        when CertificationPathStatus::APPROVING_BY_MANAGEMENT
          # Create GORD manager task to quick check and approve
          Task.find_or_create_by(taskable: self,
                     task_description_id: GSB_TRUST_MNGR_APPROVE,
                     application_role: User.roles[:gsb_trust_manager],
                     project: self.project,
                     certification_path: self)
          # Destroy project manager tasks to process verification comments
          Task.where(taskable: self, task_description_id: PROJ_MNGR_PROC_VERIFICATION_APPEAL).delete_all
          # IF APPEAL IS SKIPPED
          # Destroy project manager tasks to process verification comments
          Task.where(taskable: self, task_description_id: PROJ_MNGR_PROC_VERIFICATION).delete_all
        when CertificationPathStatus::APPROVING_BY_TOP_MANAGEMENT
          # Create GORD top manager task to approve
          Task.find_or_create_by(taskable: self,
                     task_description_id: GSB_TRUST_TOP_MNGR_APPROVE,
                     application_role: User.roles[:gsb_trust_top_manager],
                     project: self.project,
                     certification_path: self)
          # Destroy GORD manager tasks to approve
          Task.where(taskable: self, task_description_id: GSB_TRUST_MNGR_APPROVE).delete_all
        when CertificationPathStatus::CERTIFIED
          # Destroy GORD top manager tasks to approve
          # Task.where(taskable: self, task_description_id: GSB_TRUST_TOP_MNGR_APPROVE).delete_all

          # Destroy all certification path tasks
          Task.where(certification_path: self).delete_all

          # Create project CGP task to fill the report information
          Task.find_or_create_by(taskable: self,
            task_description_id: CGP_CERTIFICATION_REPORT_INFORMATION,
            project_role: ProjectsUser.roles[:cgp_project_manager],
            project: self.project,
            certification_path: self)

        when CertificationPathStatus::NOT_CERTIFIED
          # Destroy all certification path tasks
          Task.where(certification_path: self).delete_all
      end
    end
  end

  def handle_main_scheme_mix_selected_changed
    if self.saved_change_to_main_scheme_mix_selected?
      if self.main_scheme_mix_selected?
        Task.where(taskable: self, task_description_id: SYS_ADMIN_SELECT_MAIN_SCHEME).delete_all
      end
    end
  end

  def handle_updated_scheme_mix_criterion
    handle_criterion_status_changed
    handle_criterion_assignment_changed
    handle_criterion_due_date_changed
    handle_criterion_pcr_review_draft_changed
    handle_criterion_in_review_changed
    handle_criterion_screened_changed
  end

  def handle_criterion_status_changed
    if self.saved_change_to_status?
      case SchemeMixCriterion.statuses[self.status]
        when SchemeMixCriterion.statuses[:submitting], SchemeMixCriterion.statuses[:submitting_after_appeal]
          # Remove CGP task to advance certification path status
          Task.where(taskable: self.scheme_mix.certification_path, task_description_id: PROJ_MNGR_SUB_APPROVE).delete_all
        when SchemeMixCriterion.statuses[:submitted], SchemeMixCriterion.statuses[:submitted_after_appeal]
          Task.where(taskable: self, task_description_id: [CERT_MEM_REVIEW, CERT_MNGR_REVIEW, CERT_MNGR_PUBLISH_REVIEW, PROJ_MNGR_REVIEW, CERT_MNGR_OVERDUE]).delete_all
          # Check if certification with status 'submitted' has no linked criteria in status 'submitting'
          if CertificationPath.joins(:scheme_mixes)
                     .where(id: self.scheme_mix.certification_path.id, certification_path_status_id: [CertificationPathStatus::SUBMITTING, CertificationPathStatus::SUBMITTING_AFTER_APPEAL])
                     .where.not('exists(select smc.id from scheme_mix_criteria smc where smc.scheme_mix_id = scheme_mixes.id and smc.status in (?))', [SchemeMixCriterion.statuses[:submitting],SchemeMixCriterion.statuses[:submitting_after_appeal]])
                     .count.nonzero?
            # Create project manager task to advance certification path status
            Task.find_or_create_by(taskable: self.scheme_mix.certification_path,
                       task_description_id: PROJ_MNGR_SUB_APPROVE,
                       project_role: ProjectsUser.roles[:cgp_project_manager],
                       project: self.scheme_mix.certification_path.project,
                       certification_path: self.scheme_mix.certification_path)
          end
          # Destroy project manager tasks to set criterion status to 'submitted'
          Task.where(taskable: self, task_description_id: PROJ_MNGR_CRIT_APPROVE).delete_all
        when SchemeMixCriterion.statuses[:verifying], SchemeMixCriterion.statuses[:verifying_after_appeal]
          # Remove certification manager task to advance certification path status
          Task.where(taskable: self.scheme_mix.certification_path, task_description_id: CERT_MNGR_VERIFICATION_APPROVE).delete_all
          if !self.saved_change_to_certifier_id?
            if self.certifier_id.nil?
              # Create certification manager task to assign certifier to the criterion
              if self.verifying?
                if Task.find_by(taskable: self.scheme_mix.certification_path, task_description_id: CERT_MNGR_ASSIGN_FOR_VERIFICATION).nil?
                  Task.find_or_create_by(taskable: self.scheme_mix.certification_path,
                             task_description_id: CERT_MNGR_ASSIGN_FOR_VERIFICATION,
                             project_role: ProjectsUser.roles[:certification_manager],
                             project: self.scheme_mix.certification_path.project,
                             certification_path: self.scheme_mix.certification_path)
                end
              elsif self.verifying_after_appeal?
                if Task.find_by(taskable: self.scheme_mix.certification_path, task_description_id: CERT_MNGR_ASSIGN_FOR_VERIFICATION_AFTER_APPEAL).nil?
                  Task.find_or_create_by(taskable: self.scheme_mix.certification_path,
                                               task_description_id: CERT_MNGR_ASSIGN_FOR_VERIFICATION_AFTER_APPEAL,
                                               project_role: ProjectsUser.roles[:certification_manager],
                                               project: self.scheme_mix.certification_path.project,
                                               certification_path: self.scheme_mix.certification_path)
                end
              end
            else
              # Create certifier team member task to verify the criterion
              Task.find_or_create_by(taskable: self,
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
            # Create certification manager task to advance certification path status
            Task.find_or_create_by(taskable: self.scheme_mix.certification_path,
                       task_description_id: CERT_MNGR_VERIFICATION_APPROVE,
                       project_role: ProjectsUser.roles[:certification_manager],
                       project: self.scheme_mix.certification_path.project,
                       certification_path: self.scheme_mix.certification_path)
          end
          # Destroy certifier tasks to verify criterion
          Task.where(taskable: self, task_description_id: CERT_MEM_VERIFY).delete_all
          # Destroy certification manager tasks to assign certifier team members to the criterion
          if self.scheme_mix.certification_path.scheme_mix_criteria.unassigned.where(status: [SchemeMixCriterion.statuses[:verifying], SchemeMixCriterion.statuses[:verifying_after_appeal]]).count.zero?
            Task.where(taskable: self.scheme_mix.certification_path, task_description_id: [CERT_MNGR_ASSIGN_FOR_VERIFICATION, CERT_MNGR_ASSIGN_FOR_VERIFICATION_AFTER_APPEAL]).delete_all
          end
          if self.due_date.present? && self.due_date < Date.current
            # Destroy certification manager tasks to follow up overdue tasks
            Task.where(taskable: self, task_description_id: CERT_MNGR_OVERDUE).delete_all
          end
      end
    end
  end

  def handle_criterion_assignment_changed
    if self.saved_change_to_certifier_id?
      if self.certifier_id.nil?
        # Create certification manager task to assign certifier to the criterion
        if self.verifying?
          if Task.find_by(taskable: self.scheme_mix.certification_path, task_description_id: CERT_MNGR_ASSIGN_FOR_VERIFICATION).nil?
            Task.find_or_create_by(taskable: self.scheme_mix.certification_path,
                       task_description_id: CERT_MNGR_ASSIGN_FOR_VERIFICATION,
                       project_role: ProjectsUser.roles[:certification_manager],
                       project: self.scheme_mix.certification_path.project,
                       certification_path: self.scheme_mix.certification_path)
          end
        elsif self.verifying_after_appeal?
          if Task.find_by(taskable: self.scheme_mix.certification_path, task_description_id: CERT_MNGR_ASSIGN_FOR_VERIFICATION_AFTER_APPEAL).nil?
            Task.find_or_create_by(taskable: self.scheme_mix.certification_path,
                       task_description_id: CERT_MNGR_ASSIGN_FOR_VERIFICATION_AFTER_APPEAL,
                       project_role: ProjectsUser.roles[:certification_manager],
                       project: self.scheme_mix.certification_path.project,
                       certification_path: self.scheme_mix.certification_path)
          end
        elsif self.scheme_mix.certification_path.in_screening? && !self.screened
          if Task.find_by(taskable: self.scheme_mix.certification_path, task_description_id: CERT_MNGR_ASSIGN_FOR_SCREENING).nil?
            Task.find_or_create_by(taskable: self.scheme_mix.certification_path,
                        task_description_id: CERT_MNGR_ASSIGN_FOR_SCREENING,
                        project_role: ProjectsUser.roles[:certification_manager],
                        project: self.scheme_mix.certification_path.project,
                        certification_path: self.scheme_mix.certification_path)
          end
        elsif self.scheme_mix.certification_path.in_submission? && self.scheme_mix.certification_path.pcr_track? && self.in_submission?
          if Task.find_by(taskable: self, task_description_id: CERT_MNGR_REVIEW).nil?
            # Create certification manager task to provide a PCR review comment
            Task.find_or_create_by(taskable: self,
                        task_description_id: CERT_MNGR_REVIEW,
                        project_role: ProjectsUser.roles[:certification_manager],
                        project: self.scheme_mix.certification_path.project,
                        certification_path: self.scheme_mix.certification_path)
          end
        end
        # Destroy all certifier tasks for this criterion
        Task.where(taskable: self, task_description_id: [CERT_MEM_VERIFY, CERT_MEM_SCREEN, CERT_MEM_REVIEW]).delete_all
      else
        # Destroy all certifier tasks for this criterion
        Task.where(taskable: self, task_description_id: [CERT_MEM_VERIFY, CERT_MEM_SCREEN, CERT_MEM_REVIEW, CERT_MNGR_REVIEW]).delete_all
        if self.in_verification?
          # Create certifier task to verify the criterion
          Task.find_or_create_by(taskable: self,
                      task_description_id: CERT_MEM_VERIFY,
                      user: self.certifier,
                      project: self.scheme_mix.certification_path.project,
                      certification_path: self.scheme_mix.certification_path)
        elsif self.scheme_mix.certification_path.in_screening? && !self.screened
          # Create certifier task to screen the criterion
          Task.find_or_create_by(taskable: self,
                      task_description_id: CERT_MEM_SCREEN,
                      user: self.certifier,
                      project: self.scheme_mix.certification_path.project,
                      certification_path: self.scheme_mix.certification_path)
        elsif self.scheme_mix.certification_path.in_submission? && self.scheme_mix.certification_path.pcr_track? && self.in_submission?
          # Create certifier task to provide a PCR review for this criterion
          Task.find_or_create_by(taskable: self,
                      task_description_id: CERT_MEM_REVIEW,
                      user: self.certifier,
                      project: self.scheme_mix.certification_path.project,
                      certification_path: self.scheme_mix.certification_path)
        end
        # Destroy all certification manager tasks to assign certifiers to this criterion
        if self.scheme_mix.certification_path.scheme_mix_criteria.unassigned.where(status: [SchemeMixCriterion.statuses[:verifying], SchemeMixCriterion.statuses[:verifying_afer_appeal]]).count.zero?
          Task.where(taskable: self.scheme_mix.certification_path, task_description_id: [CERT_MNGR_ASSIGN_FOR_VERIFICATION, CERT_MNGR_ASSIGN_FOR_VERIFICATION_AFTER_APPEAL]).delete_all
        end
        if self.scheme_mix.certification_path.in_screening? && self.scheme_mix.certification_path.scheme_mix_criteria.unassigned.where(screened: false).count.zero?
          Task.where(taskable: self.scheme_mix.certification_path, task_description_id: CERT_MNGR_ASSIGN_FOR_SCREENING).delete_all
        end
      end
    end
  end

  def handle_criterion_due_date_changed
    if self.saved_change_to_due_date?
      if (self.due_date_before_last_save.present? && (self.due_date_before_last_save < Date.current)) && (self.due_date.blank? || (self.due_date > Date.current))
        # Destroy certification manager tasks to follow up overdue tasks
        Task.where(taskable: self, task_description_id: CERT_MNGR_OVERDUE).delete_all
      end
    end
  end

  def handle_criterion_pcr_review_draft_changed
    if self.saved_change_to_pcr_review_draft? && self.pcr_review_draft.present?
      Task.where(taskable: self, task_description_id: CERT_MEM_REVIEW).delete_all
      if Task.find_by(taskable: self, task_description_id: CERT_MNGR_PUBLISH_REVIEW).nil?
        # Create certification manager task to publish the draft PCR review comment
        Task.find_or_create_by(taskable: self,
                    task_description_id: CERT_MNGR_PUBLISH_REVIEW,
                    project_role: ProjectsUser.roles[:certification_manager],
                    project: self.scheme_mix.certification_path.project,
                    certification_path: self.scheme_mix.certification_path)
      end
      if self.due_date.present? && self.due_date < Date.current
        # Destroy certification manager tasks to follow up overdue tasks
        Task.where(taskable: self, task_description_id: CERT_MNGR_OVERDUE).delete_all
      end
    end
  end

  def handle_criterion_in_review_changed
    if self.saved_change_to_in_review?
      if self.in_review?
        Task.where(taskable: self, task_description_id: PROJ_MNGR_REVIEW).delete_all
        if Task.find_by(taskable: self, task_description_id: CERT_MNGR_REVIEW).nil?
          # Create certification manager task to provide a PCR review comment
          Task.find_or_create_by(taskable: self,
                      task_description_id: CERT_MNGR_REVIEW,
                      project_role: ProjectsUser.roles[:certification_manager],
                      project: self.scheme_mix.certification_path.project,
                      certification_path: self.scheme_mix.certification_path)
        end
      else
        Task.where(taskable: self, task_description_id: [CERT_MNGR_REVIEW, CERT_MEM_REVIEW, CERT_MNGR_PUBLISH_REVIEW]).delete_all
        if Task.find_by(taskable: self, task_description_id: PROJ_MNGR_REVIEW).nil?
          Task.find_or_create_by(taskable: self, task_description_id: PROJ_MNGR_REVIEW, project_role: ProjectsUser.roles[:cgp_project_manager], project: self.scheme_mix.certification_path.project, certification_path: self.scheme_mix.certification_path)
        end
        if self.due_date.present? && self.due_date < Date.current
          # Destroy certification manager tasks to follow up overdue tasks
          Task.where(taskable: self, task_description_id: CERT_MNGR_OVERDUE).delete_all
        end
      end
    end
  end

  def handle_criterion_screened_changed
    if self.saved_change_to_screened? && self.scheme_mix.certification_path.in_screening?
      if self.screened
        # Destroy certifier tasks to screen criterion
        Task.where(taskable: self, task_description_id: CERT_MEM_SCREEN).delete_all

        if self.scheme_mix.certification_path.scheme_mix_criteria.where(screened: false).count.zero?
          # Create certification manager task to advance certification path status
          Task.find_or_create_by(taskable: self.scheme_mix.certification_path,
                      task_description_id: CERT_MNGR_SCREENING_APPROVE,
                      project_role: ProjectsUser.roles[:certification_manager],
                      project: self.scheme_mix.certification_path.project,
                      certification_path: self.scheme_mix.certification_path)
        end

        if self.due_date.present? && self.due_date < Date.current
          # Destroy certification manager tasks to follow up overdue tasks
          Task.where(taskable: self, task_description_id: CERT_MNGR_OVERDUE).delete_all
        end
      else
        # Remove certification manager task to advance certification path status
        Task.where(taskable: self.scheme_mix.certification_path, task_description_id: CERT_MNGR_SCREENING_APPROVE).delete_all
      end
    end
  end

  def handle_updated_requirement_datum
    handle_requirement_status_changed
    handle_requirement_assignment_changed
    handle_requirement_due_date_changed
  end

  def handle_requirement_status_changed
    if self.saved_change_to_status?
      case RequirementDatum.statuses[self.status]
        when RequirementDatum.statuses[:required]
          if !self.saved_change_to_user_id?
            if self.user_id.nil?
              if self.scheme_mix_criteria.first.submitting?
                # Create project manager task to assign a project team member to the requirement
                if Task.find_by(taskable: self.scheme_mix_criteria.first.scheme_mix.certification_path, task_description_id: PROJ_MNGR_ASSIGN_FOR_SUBMITTAL).nil?
                  Task.find_or_create_by(taskable: self.scheme_mix_criteria.first.scheme_mix.certification_path,
                             task_description_id: PROJ_MNGR_ASSIGN_FOR_SUBMITTAL,
                             project_role: ProjectsUser.roles[:cgp_project_manager],
                             project: self.scheme_mix_criteria.first.scheme_mix.certification_path.project,
                             certification_path: self.scheme_mix_criteria.first.scheme_mix.certification_path)
                end
              elsif self.scheme_mix_criteria.first.submitting_after_appeal?
                # Create project manager task to assign a project team member to the requirement
                if Task.find_by(taskable: self.scheme_mix_criteria.first.scheme_mix.certification_path, task_description_id: PROJ_MNGR_ASSIGN_FOR_SUBMITTAL_AFTER_APPEAL).nil?
                  Task.find_or_create_by(taskable: self.scheme_mix_criteria.first.scheme_mix.certification_path,
                             task_description_id: PROJ_MNGR_ASSIGN_FOR_SUBMITTAL_AFTER_APPEAL,
                             project_role: ProjectsUser.roles[:cgp_project_manager],
                             project: self.scheme_mix_criteria.first.scheme_mix.certification_path.project,
                             certification_path: self.scheme_mix_criteria.first.scheme_mix.certification_path)
                end
              end
            else
              # Create project team member task to provide the requirement
              if Task.find_by(taskable: self.scheme_mix_criteria.first, task_description_id: PROJ_MEM_REQ, user: self.user).nil?
                Task.find_or_create_by(taskable: self.scheme_mix_criteria.first,
                            task_description_id: PROJ_MEM_REQ,
                            user: self.user,
                            project: self.scheme_mix_criteria.first.scheme_mix.certification_path.project,
                            certification_path: self.scheme_mix_criteria.first.scheme_mix.certification_path)
              end
            end
          end
          # Destroy project manager tasks to set criterion status to complete
          Task.where(taskable: self.scheme_mix_criteria.first,
                          task_description_id: PROJ_MNGR_CRIT_APPROVE,
                          project_role: ProjectsUser.roles[:cgp_project_manager],
                          project: self.scheme_mix_criteria.first.scheme_mix.certification_path.project).delete_all
        when RequirementDatum.statuses[:provided], RequirementDatum.statuses[:not_required]
          # Check if criterion with status 'submitting'/'submitting after appeal' has no linked requirements in status 'required'
          if SchemeMixCriterion.joins(:scheme_mix_criteria_requirement_data)
                     .where(id: self.scheme_mix_criteria.first.id, status: [SchemeMixCriterion.statuses[:submitting],SchemeMixCriterion.statuses[:submitting_after_appeal]])
                     .where.not('exists(select rd.id from requirement_data rd inner join scheme_mix_criteria_requirement_data smcrd on smcrd.requirement_datum_id = rd.id where smcrd.scheme_mix_criterion_id = scheme_mix_criteria.id and rd.status = ?)', RequirementDatum.statuses[:required])
                     .count.nonzero?
            # Create project manager task to advance criterion status
            Task.find_or_create_by(taskable: self.scheme_mix_criteria.first,
                        task_description_id: PROJ_MNGR_CRIT_APPROVE,
                        project_role: ProjectsUser.roles[:cgp_project_manager],
                        project: self.scheme_mix_criteria.first.scheme_mix.certification_path.project,
                        certification_path: self.scheme_mix_criteria.first.scheme_mix.certification_path)
          end
          unless self.saved_change_to_user_id?
            count = self.scheme_mix_criteria.first.requirement_data.where(status: RequirementDatum.statuses[:required], user: self.user).count
            if !count.nil? && count.zero?
              Task.where(taskable: self.scheme_mix_criteria.first, task_description_id: PROJ_MEM_REQ, user: self.user).delete_all
            end
          end
          # Destroy project manager tasks to assign project team members to requirement and project team member tasks to provide the requirement
          if self.scheme_mix_criteria.first.scheme_mix.certification_path.requirement_data.unassigned.where(status: RequirementDatum.statuses[:required]).count.zero?
            Task.where(taskable: self.scheme_mix_criteria.first.scheme_mix.certification_path, task_description_id: [PROJ_MNGR_ASSIGN_FOR_SUBMITTAL, PROJ_MNGR_ASSIGN_FOR_SUBMITTAL_AFTER_APPEAL]).delete_all
          end
          if self.due_date.present? && self.due_date < Date.current
            # Destroy project manager tasks to follow up overdue tasks
            Task.where(taskable: self, task_description_id: PROJ_MNGR_OVERDUE).delete_all
          end
      end
    end
  end

  def handle_requirement_assignment_changed
    if self.saved_change_to_user_id?
      if self.user_id.nil?
        if RequirementDatum.statuses[self.status] == RequirementDatum.statuses[:required]
          if self.scheme_mix_criteria.first.submitting?
            # Create project manager task to assign project team member
            if Task.find_by(taskable: self.scheme_mix_criteria.first.scheme_mix.certification_path, task_description_id: PROJ_MNGR_ASSIGN_FOR_SUBMITTAL).nil?
              Task.find_or_create_by(taskable: self.scheme_mix_criteria.first.scheme_mix.certification_path,
                         task_description_id: PROJ_MNGR_ASSIGN_FOR_SUBMITTAL,
                         project_role: ProjectsUser.roles[:cgp_project_manager],
                         project: self.scheme_mix_criteria.first.scheme_mix.certification_path.project,
                         certification_path: self.scheme_mix_criteria.first.scheme_mix.certification_path)
            end
          elsif self.scheme_mix_criteria.first.submitting_after_appeal?
            # Create project manager task to assign project team member
            if Task.find_by(taskable: self.scheme_mix_criteria.first.scheme_mix.certification_path, task_description_id: PROJ_MNGR_ASSIGN_FOR_SUBMITTAL_AFTER_APPEAL).nil?
              Task.find_or_create_by(taskable: self.scheme_mix_criteria.first.scheme_mix.certification_path,
                         task_description_id: PROJ_MNGR_ASSIGN_FOR_SUBMITTAL_AFTER_APPEAL,
                         project_role: ProjectsUser.roles[:cgp_project_manager],
                         project: self.scheme_mix_criteria.first.scheme_mix.certification_path.project,
                         certification_path: self.scheme_mix_criteria.first.scheme_mix.certification_path)
            end
          end
        end
        # Destroy project team member tasks to provide the requirement
        if self.scheme_mix_criteria.first.requirement_data.where(status: RequirementDatum.statuses[:required], user_id: self.user_id_before_last_save).count.zero?
          Task.where(taskable: self, task_description_id: PROJ_MEM_REQ, user_id: self.user_id_before_last_save).delete_all
        end
      else
        # Destroy project team member tasks to provide the requirement (which are assigned to another user)
        if self.scheme_mix_criteria.first.requirement_data.where(status: RequirementDatum.statuses[:required], user_id: self.user_id_before_last_save).count.zero?
          Task.where(taskable: self, task_description_id: PROJ_MEM_REQ, user_id: self.user_id_before_last_save).delete_all
        end
        if RequirementDatum.statuses[self.status] == RequirementDatum.statuses[:required]
          if self.scheme_mix_criteria.first.scheme_mix.certification_path.in_submission?
            # Create project team member task to provide the requirement
            if Task.find_by(taskable: self.scheme_mix_criteria.first, task_description_id: PROJ_MEM_REQ, user: self.user).nil?
              Task.find_or_create_by(taskable: self.scheme_mix_criteria.first,
                          task_description_id: PROJ_MEM_REQ,
                          user: self.user,
                          project: self.scheme_mix_criteria.first.scheme_mix.certification_path.project,
                          certification_path: self.scheme_mix_criteria.first.scheme_mix.certification_path)
            end
          end
        end
        # Destroy project manager tasks to assign project team member
        if self.scheme_mix_criteria.first.scheme_mix.certification_path.requirement_data.unassigned.where(status: RequirementDatum.statuses[:required]).count.zero?
          Task.where(taskable: self.scheme_mix_criteria.first.scheme_mix.certification_path, task_description_id: [PROJ_MNGR_ASSIGN_FOR_SUBMITTAL, PROJ_MNGR_ASSIGN_FOR_SUBMITTAL_AFTER_APPEAL]).delete_all
        end
      end
    end
  end

  def handle_requirement_due_date_changed
    if self.saved_change_to_due_date?
      if (self.due_date_before_last_save.present? && (self.due_date_before_last_save < Date.current)) && (self.due_date.blank? || (self.due_date > Date.current))
        # Destroy project manager tasks to follow up overdue tasks
        Task.where(taskable: self, task_description_id: PROJ_MNGR_OVERDUE).delete_all
      end
    end
  end

  def handle_updated_scheme_mix_criteria_document
    handle_document_status_changed
  end

  def handle_document_status_changed
    if self.saved_change_to_status?
      case SchemeMixCriteriaDocument.statuses[self.status]
        when SchemeMixCriteriaDocument.statuses[:awaiting_approval]
          # Create project manager task to approve/reject document
          if Task.find_by(taskable: self.scheme_mix_criterion, task_description_id: PROJ_MNGR_DOC_APPROVE).nil?
            Task.find_or_create_by(taskable: self.scheme_mix_criterion,
                        task_description_id: PROJ_MNGR_DOC_APPROVE,
                        project_role: ProjectsUser.roles[:cgp_project_manager],
                        project: self.scheme_mix_criterion.scheme_mix.certification_path.project,
                        certification_path: self.scheme_mix_criterion.scheme_mix.certification_path)
          end
        when SchemeMixCriteriaDocument.statuses[:approved], SchemeMixCriteriaDocument.statuses[:rejected]
          # Destroy project managers tasks to approve/reject document
          if self.scheme_mix_criterion.scheme_mix_criteria_documents.where(status: SchemeMixCriteriaDocument.statuses[:awaiting_approval]).count.zero?
            Task.where(taskable: self.scheme_mix_criterion, task_description_id: PROJ_MNGR_DOC_APPROVE).delete_all
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
          if Task.find_by(taskable: certification_path, task_description_id: PROJ_MNGR_ASSIGN_FOR_SUBMITTAL).nil?
            if certification_path.requirement_data.unassigned.required.count.nonzero?
              Task.find_or_create_by(taskable: certification_path,
                         task_description_id: PROJ_MNGR_ASSIGN_FOR_SUBMITTAL,
                         project_role: ProjectsUser.roles[:cgp_project_manager],
                         project: self.project,
                         certification_path: certification_path)
            end
          end
        end
        project.certification_paths.with_status(CertificationPathStatus::SUBMITTING_AFTER_APPEAL).each do |certification_path|
          if Task.find_by(taskable: certification_path, task_description_id: PROJ_MNGR_ASSIGN_FOR_SUBMITTAL_AFTER_APPEAL).nil?
            if certification_path.requirement_data.unassigned.required.count.nonzero?
              Task.find_or_create_by(taskable: certification_path,
                         task_description_id: PROJ_MNGR_ASSIGN_FOR_SUBMITTAL_AFTER_APPEAL,
                         project_role: ProjectsUser.roles[:cgp_project_manager],
                         project: self.project,
                         certification_path: certification_path)
            end
          end
        end
      # A certifier is unassigned from project
      when ProjectsUser.roles[:certifier]
        # Create certification manager tasks to assign certifiers to criteria
        project.certification_paths.with_status(CertificationPathStatus::VERIFYING).each do |certification_path|
          if Task.find_by(taskable: certification_path, task_description_id: CERT_MNGR_ASSIGN_FOR_VERIFICATION).nil?
            if certification_path.scheme_mix_criteria.unassigned.verifying.count.nonzero?
              Task.find_or_create_by(taskable: certification_path,
                         task_description_id: CERT_MNGR_ASSIGN_FOR_VERIFICATION,
                         project_role: ProjectsUser.roles[:certification_manager],
                         project: self.project,
                         certification_path: certification_path)
            end
          end
        end
        project.certification_paths.with_status(CertificationPathStatus::VERIFYING).each do |certification_path|
          if Task.find_by(taskable: certification_path, task_description_id: CERT_MNGR_ASSIGN_FOR_VERIFICATION_AFTER_APPEAL).nil?
            if certification_path.scheme_mix_criteria.unassigned.verifying.count.nonzero?
              Task.find_or_create_by(taskable: certification_path,
                         task_description_id: CERT_MNGR_ASSIGN_FOR_VERIFICATION_AFTER_APPEAL,
                         project_role: ProjectsUser.roles[:certification_manager],
                         project: self.project,
                         certification_path: certification_path)
            end
          end
        end
      # A certification manager is unassigned from project
      when ProjectsUser.roles[:certification_manager]
        certification_manager = self.project&.projects_users&.where(certification_team_type: self.certification_team_type, role: ProjectsUser.roles[:certification_manager])
       
        unless certification_manager.present?
          # Create system admin task to assign a certification manager
          Task.find_or_create_by(taskable: self.project,
                     task_description_id: SYS_ADMIN_ASSIGN,
                     application_role: User.roles[:gsb_trust_admin],
                     project: self.project)
        end
    end
  end

  def handle_updated_certification_path_report
    if self.is_released?
      Task.where(certification_path_id: self.certification_path_id).delete_all
    end
  end

  def handle_projects_users_tasks
    self.projects_users&.destroy_all
    Task.where(project_id: self.id).delete_all
  end
end