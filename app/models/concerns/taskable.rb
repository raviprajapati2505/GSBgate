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
  PROJ_MNGR_PROC_SCREENING = 10
  SYS_ADMIN_PCR_ALLOWED = 11
  SYS_ADMIN_PCR_APPROVE = 12
  PROJ_MNGR_PROC_PCR = 14
  CERT_MEM_VERIFY = 16
  CERT_MNGR_VERIFICATION_APPROVE = 17
  PROJ_MNGR_PROC_VERIFICATION = 18
  SYS_ADMIN_APPEAL_APPROVE = 19
  PROJ_MNGR_PROC_VERIFICATION_APPEAL = 24
  GORD_MNGR_APPROVE = 25
  GORD_TOP_MNGR_APPROVE = 26
  PROJ_MNGR_DOWNLOAD = 28
  PROJ_MNGR_DOC_APPROVE = 29
  PROJ_MNGR_APPLY = 30
  PROJ_MNGR_ASSIGN_AFTER_APPEAL = 31
  PROJ_MNGR_GEN = 32
  SYS_ADMIN_DURATION = 33

  included do
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
    ProjectTask.create(task_description_id: PROJ_MNGR_APPLY, project_role: ProjectsUser.roles[:project_manager], project: self)
    if self.location_plan_file.blank? || self.site_plan_file.blank? || self.design_brief_file.blank? || self.project_narrative_file.blank?
      # Create a project manager task to provide the 'general submittal' documents
      ProjectTask.create(task_description_id: PROJ_MNGR_GEN, project_role: ProjectsUser.roles[:project_manager], project: self)
    end
  end

  def handle_created_projects_user
    case ProjectsUser.roles[self.role]
      # A certifier manager is assigned to project
      when ProjectsUser.roles[:certifier_manager]
        # Destroy all system admin tasks to assign a certifier manager for this project
        ProjectTask.delete_all(task_description_id: SYS_ADMIN_ASSIGN, project: self.project)
    end
  end

  def handle_created_certification_path
    unless self.project.certifier_manager_assigned?
      # Create system admin task to assign a certifier manager
      ProjectTask.create(task_description_id: SYS_ADMIN_ASSIGN,
                         application_role: User.roles[:system_admin],
                         project: self.project)
    end
    # Create system admin task to advance the certification path status
    CertificationPathTask.create(task_description_id: SYS_ADMIN_REG_APPROVE,
                                 application_role: User.roles[:system_admin],
                                 project: self.project,
                                 certification_path: self)
    # Destroy project manager tasks to apply for a certification path
    ProjectTask.delete_all(task_description_id: PROJ_MNGR_APPLY, project: self.project)
    handle_pcr_track_changed
  end

  def handle_created_scheme_mix_criteria_document
    # Create project manager task to approve/reject document
    SchemeMixCriterionDocumentTask.create(task_description_id: PROJ_MNGR_DOC_APPROVE,
                                          project_role: ProjectsUser.roles[:project_manager],
                                          project: self.scheme_mix_criterion.scheme_mix.certification_path.project,
                                          scheme_mix_criteria_document: self)
  end

  def handle_updated_project
    if self.location_plan_file_changed? || self.site_plan_file_changed? || self.design_brief_file_changed? || self.project_narrative_file_changed?
      if self.location_plan_file.blank? || self.site_plan_file.blank? || self.design_brief_file.blank? || self.project_narrative_file.blank?
        # Create a project manager task to provide the 'general submittal' documents if it not already exists
        unless self.location_plan_file_was.blank? || self.site_plan_file_was.blank? || self.design_brief_file_was.blank? || self.project_narrative_file_was.blank?
          # Create a project manager task to provide the 'general submittal' documents
          ProjectTask.create(task_description_id: PROJ_MNGR_GEN, project_role: ProjectsUser.roles[:project_manager], project: self)
        end
      else
        ProjectTask.delete_all(task_description_id: PROJ_MNGR_GEN, project: self)
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
        when ProjectsUser.roles[:certifier_manager]
          # Destroy all system admin tasks to assign a certifier manager for this project
          ProjectTask.delete_all(task_description_id: SYS_ADMIN_ASSIGN, project: self.project)
      end
    end
  end

  def handle_updated_certification_path
    handle_certification_status_changed
    handle_pcr_track_changed
    handle_pcr_track_allowed_changed
  end

  def handle_certification_status_changed
    if self.certification_path_status_id_changed?
      case self.certification_path_status_id
        when CertificationPathStatus::ACTIVATING
          #
        when CertificationPathStatus::SUBMITTING
          # Create project manager tasks to assign project team members to requirements
          # self.requirement_data.unassigned.required.each do |requirement_datum|
          #   RequirementDatumTask.create(task_description_id: PROJ_MNGR_ASSIGN,
          #                               project_role: ProjectsUser.roles[:project_manager],
          #                               project: self.project,
          #                               requirement_datum: requirement_datum)
          # end
          if self.requirement_data.unassigned.required.count.nonzero?
            # Create project manager task to assign project team members to requirements
            CertificationPathTask.create(task_description_id: PROJ_MNGR_ASSIGN,
                                         project_role: ProjectsUser.roles[:project_manager],
                                         project: self.project,
                                         certification_path: self)
          end
          # Destroy system admin tasks to advance status
          CertificationPathTask.delete_all(task_description_id: SYS_ADMIN_REG_APPROVE, certification_path: self)
        when CertificationPathStatus::SCREENING
          # ASSUMING CERTIFIER MANAGER IS RESPONSIBLE FOR SCREENING !
          # ---------------------------------------------------------
          # Create certifier manager task to screen certification path
          CertificationPathTask.create(task_description_id: CERT_MNGR_SCREEN,
                                       project_role: ProjectsUser.roles[:certifier_manager],
                                       project: self.project,
                                       certification_path: self)
          # Destroy project manager tasks to advance status
          CertificationPathTask.delete_all(task_description_id: PROJ_MNGR_SUB_APPROVE, certification_path: self)
        when CertificationPathStatus::SUBMITTING_AFTER_SCREENING
          # Create project manager task to process screening comments
          CertificationPathTask.create(task_description_id: PROJ_MNGR_PROC_SCREENING,
                                       project_role: ProjectsUser.roles[:project_manager],
                                       project: self.project,
                                       certification_path: self)
          # Destroy certifier manager tasks to screen certification path
          CertificationPathTask.delete_all(task_description_id: CERT_MNGR_SCREEN, certification_path: self)
        when CertificationPathStatus::PROCESSING_PCR_PAYMENT
          if self.pcr_track_allowed == true
            # Create system admin task to advance the certification path status
            CertificationPathTask.create(task_description_id: SYS_ADMIN_PCR_APPROVE,
                                         application_role: User.roles[:system_admin],
                                         project: self.project,
                                         certification_path: self)
          end
          # Destroy project manager tasks to process screening comments
          CertificationPathTask.delete_all(task_description_id: PROJ_MNGR_PROC_SCREENING, certification_path: self)
        when CertificationPathStatus::SUBMITTING_PCR
          # ASSUMING PROJECT MANAGER IS RESPONSIBLE FOR TAKING ACTION !
          # -----------------------------------------------------------
          # Create project manager task to advance status
          CertificationPathTask.create(task_description_id: PROJ_MNGR_PROC_PCR,
                                       project_role: ProjectsUser.roles[:project_manager],
                                       project: self.project,
                                       certification_path: self)
          # Create certifier manager tasks to assign certifier team members to criteria
          # self.scheme_mix_criteria.unassigned.submitted.each do |scheme_mix_criterion|
          #   SchemeMixCriterionTask.create(task_description_id: CERT_MNGR_ASSIGN,
          #                                 project_role: ProjectsUser.roles[:certifier_manager],
          #                                 project: self.project,
          #                                 scheme_mix_criterion: scheme_mix_criterion)
          # end
          # Create certifier manager task to assign certifier team members to criteria
          if self.scheme_mix_criteria.unassigned.submitted.count.nonzero?
            CertificationPathTask.create(task_description_id: CERT_MNGR_ASSIGN,
                                         project_role: ProjectsUser.roles[:certifier_manager],
                                         project: self.project,
                                         certification_path: self)
          end
          # Destroy system admin tasks to advance the certification path status
          CertificationPathTask.delete_all(task_description_id: SYS_ADMIN_PCR_APPROVE, certification_path: self)
          # IF PROCESSING PCR PAYMENT IS SKIPPED
          # Destroy project manager tasks to process screening comments
          CertificationPathTask.delete_all(task_description_id: PROJ_MNGR_PROC_SCREENING, certification_path: self)
        when CertificationPathStatus::VERIFYING
          self.scheme_mix_criteria.submitted.where.not(certifier: nil).each do |scheme_mix_criterion|
            # Create certifier team member task to verify the criterion
            SchemeMixCriterionTask.create(task_description_id: CERT_MEM_VERIFY,
                                          user: scheme_mix_criterion.certifier,
                                          project: self.project,
                                          scheme_mix_criterion: scheme_mix_criterion)
          end
          # Destroy project manager tasks to process PCR comments
          CertificationPathTask.delete_all(task_description_id: PROJ_MNGR_PROC_PCR, certification_path: self)
          # IF PCR IS SKIPPED
          # Destroy project manager tasks to process screening comments
          CertificationPathTask.delete_all(task_description_id: PROJ_MNGR_PROC_SCREENING, certification_path: self)
        when CertificationPathStatus::ACKNOWLEDGING
          # Create project manager task to process verification comments
          CertificationPathTask.create(task_description_id: PROJ_MNGR_PROC_VERIFICATION,
                                       project_role: ProjectsUser.roles[:project_manager],
                                       project: self.project,
                                       certification_path: self)
          # Destroy certifier manager tasks to advance status
          CertificationPathTask.delete_all(task_description_id: CERT_MNGR_VERIFICATION_APPROVE, certification_path: self)
        when CertificationPathStatus::PROCESSING_APPEAL_PAYMENT
          # Create system admin task to check appeal payment
          CertificationPathTask.create(task_description_id: SYS_ADMIN_APPEAL_APPROVE,
                                       application_role: User.roles[:system_admin],
                                       project: self.project,
                                       certification_path: self)
          # Destroy project manager tasks to process verification comments
          CertificationPathTask.delete_all(task_description_id: PROJ_MNGR_PROC_VERIFICATION, certification_path: self)
        when CertificationPathStatus::SUBMITTING_AFTER_APPEAL
          # Create project manager tasks to assign project team members to requirements
          # self.requirement_data.unassigned.required.each do |requirement_datum|
          #   RequirementDatumTask.create(task_description_id: PROJ_MNGR_ASSIGN_AFTER_APPEAL,
          #                               project_role: ProjectsUser.roles[:project_manager],
          #                               project: self.project,
          #                               requirement_datum: requirement_datum)
          # end
          # Create project manager task to assign project team members to requirements
          if self.requirement_data.unassigned.required.count.nonzero?
            CertificationPathTask.create(task_description_id: PROJ_MNGR_ASSIGN_AFTER_APPEAL,
                                         project_role: ProjectsUser.roles[:project_manager],
                                         project: self.project,
                                         certification_path: self)
          end
          # Destroy system admin tasks to check appeal payment
          CertificationPathTask.delete_all(task_description_id: SYS_ADMIN_APPEAL_APPROVE, certification_path: self)
        when CertificationPathStatus::VERIFYING_AFTER_APPEAL
          # Destroy project manager tasks to advance certification path status
          CertificationPathTask.delete_all(task_description_id: PROJ_MNGR_SUB_APPROVE, certification_path: self)
        when CertificationPathStatus::ACKNOWLEDGING_AFTER_APPEAL
          # Create project manager task to process verification comments
          CertificationPathTask.create(task_description_id: PROJ_MNGR_PROC_VERIFICATION_APPEAL,
                                       project_role: ProjectsUser.roles[:project_manager],
                                       project: self.project,
                                       certification_path: self)
          # Destroy certifier manager tasks to advance status
          CertificationPathTask.delete_all(task_description_id: CERT_MNGR_VERIFICATION_APPROVE, certification_path: self)
        when CertificationPathStatus::APPROVING_BY_MANAGEMENT
          # Create GORD manager task to quick check and approve
          CertificationPathTask.create(task_description_id: GORD_MNGR_APPROVE,
                                       application_role: User.roles[:gord_manager],
                                       project: self.project,
                                       certification_path: self)
          # Destroy project manager tasks to process verification comments
          CertificationPathTask.delete_all(task_description_id: PROJ_MNGR_PROC_VERIFICATION_APPEAL, certification_path: self)
          # IF APPEAL IS SKIPPED
          # Destroy project manager tasks to process verification comments
          CertificationPathTask.delete_all(task_description_id: PROJ_MNGR_PROC_VERIFICATION, certification_path: self)
        when CertificationPathStatus::APPROVING_BY_TOP_MANAGEMENT
          # Create GORD top manager task to approve
          CertificationPathTask.create(task_description_id: GORD_TOP_MNGR_APPROVE,
                                       application_role: User.roles[:gord_top_manager],
                                       project: self.project,
                                       certification_path: self)
          # Destroy GORD manager tasks to approve
          CertificationPathTask.delete_all(task_description_id: GORD_MNGR_APPROVE, certification_path: self)
        when CertificationPathStatus::CERTIFIED
          # Destroy GORD top manager tasks to approve
          CertificationPathTask.delete_all(task_description_id: GORD_TOP_MNGR_APPROVE, certification_path: self)
        when CertificationPathStatus::NOT_CERTIFIED
          # Destroy all certification path tasks
          CertificationPathTask.delete_all(certification_path: self)
      end
    end
  end

  def handle_pcr_track_changed
    if self.pcr_track_changed?
      if self.pcr_track == true
        if self.pcr_track_allowed == false && self.certification_path_status_id < CertificationPathStatus::PROCESSING_PCR_PAYMENT
          # Create system admin task to check PCR payment
          CertificationPathTask.create(task_description_id: SYS_ADMIN_PCR_ALLOWED,
                                       application_role: User.roles[:system_admin],
                                       project: self.project,
                                       certification_path: self)
        end
      elsif self.pcr_track_allowed == false && self.certification_path_status_id < CertificationPathStatus::PROCESSING_PCR_PAYMENT
        # Destroy system admin tasks to check PCR payment
        CertificationPathTask.delete_all(task_description_id: SYS_ADMIN_PCR_ALLOWED, certification_path: self)
      end
    end
  end

  def handle_pcr_track_allowed_changed
    if self.pcr_track_allowed_changed?
      if self.pcr_track_allowed == true
        if self.pcr_track == true && self.certification_path_status_id <= CertificationPathStatus::PROCESSING_PCR_PAYMENT
          if self.certification_path_status_id == CertificationPathStatus::PROCESSING_PCR_PAYMENT
            # Create system admin task to advance the certification path status
            CertificationPathTask.create(task_description_id: SYS_ADMIN_PCR_APPROVE,
                                         application_role: User.roles[:system_admin],
                                         project: self.project,
                                         certification_path: self)
          end
          # Destroy system admin tasks to check PCR payment
          CertificationPathTask.delete_all(task_description_id: SYS_ADMIN_PCR_ALLOWED, certification_path: self)
        end
      elsif self.pcr_track == true && self.certification_path_status_id <= CertificationPathStatus::PROCESSING_PCR_PAYMENT
        # Create system admin task to check PCR payment
        CertificationPathTask.create(task_description_id: SYS_ADMIN_PCR_ALLOWED,
                                     application_role: User.roles[:system_admin],
                                     project: self.project,
                                     certification_path: self)
        # Destroy system admin tasks to advance the certification path status
        CertificationPathTask.delete_all(task_description_id: SYS_ADMIN_PCR_APPROVE, certification_path: self)
      end
    end
  end

  def handle_updated_scheme_mix_criterion
    handle_criterion_status_changed
    handle_criterion_assignment_changed
  end

  def handle_criterion_status_changed
    if self.status_changed?
      case SchemeMixCriterion.statuses[self.status]
        when SchemeMixCriterion.statuses[:submitted], SchemeMixCriterion.statuses[:submitted_after_appeal]
          # Check if certification with status 'submitted' has no linked criteria in status 'submitting'
          if CertificationPath.joins(:scheme_mixes)
                     .where(id: self.scheme_mix.certification_path.id, certification_path_status_id: [CertificationPathStatus::SUBMITTING, CertificationPathStatus::SUBMITTING_AFTER_APPEAL])
                     .where.not('exists(select smc.id from scheme_mix_criteria smc where smc.scheme_mix_id = scheme_mixes.id and smc.status in (?))', [SchemeMixCriterion.statuses[:submitting],SchemeMixCriterion.statuses[:submitting_after_appeal]])
                     .count.nonzero?
            # Create project manager task to advance certification path status
            CertificationPathTask.create(task_description_id: PROJ_MNGR_SUB_APPROVE,
                                         project_role: ProjectsUser.roles[:project_manager],
                                         project: self.scheme_mix.certification_path.project,
                                         certification_path: self.scheme_mix.certification_path)
          end
          # Destroy project manager tasks to set criterion status to 'submitted'
          SchemeMixCriterionTask.delete_all(task_description_id: PROJ_MNGR_CRIT_APPROVE, scheme_mix_criterion: self)
        when SchemeMixCriterion.statuses[:verifying], SchemeMixCriterion.statuses[:verifying_after_appeal]
          if self.certifier_id.nil?
            # Create certifier manager task to assign certifier to the criterion
            # SchemeMixCriterionTask.create(task_description_id: CERT_MNGR_ASSIGN,
            #                               project_role: ProjectsUser.roles[:certifier_manager],
            #                               project: self.scheme_mix.certification_path.project,
            #                               scheme_mix_criterion: self)
            if CertificationPathTask.find_by(task_description_id: CERT_MNGR_ASSIGN, certification_path: self.scheme_mix.certification_path).nil?
              CertificationPathTask.create(task_description_id: CERT_MNGR_ASSIGN,
                                           project_role: ProjectsUser.roles[:certifier_manager],
                                           project: self.scheme_mix.certification_path.project,
                                           certification_path: self.scheme_mix.certification_path)
            end
          else
            # Create certifier team member task to screen the criterion
            SchemeMixCriterionTask.create(task_description_id: CERT_MEM_VERIFY,
                                          user: self.certifier,
                                          project: self.scheme_mix.certification_path.project,
                                          scheme_mix_criterion: self)
          end
        when SchemeMixCriterion.statuses[:target_achieved], SchemeMixCriterion.statuses[:target_not_achieved], SchemeMixCriterion.statuses[:target_achieved_after_appeal], SchemeMixCriterion.statuses[:target_not_achieved_after_appeal]
          # Check if certification with status 'verifying' has no linked criteria in status 'verifying'
          if CertificationPath.joins(:scheme_mixes)
                     .where(id: self.scheme_mix.certification_path.id, certification_path_status_id: [CertificationPathStatus::VERIFYING, CertificationPathStatus::VERIFYING_AFTER_APPEAL])
                     .where.not('exists(select smc.id from scheme_mix_criteria smc where smc.scheme_mix_id = scheme_mixes.id and smc.status in (?))', [SchemeMixCriterion.statuses[:verifying],SchemeMixCriterion.statuses[:verifying_after_appeal]])
                     .count.nonzero?
            # Create certifier manager task to advance certification path status
            CertificationPathTask.create(task_description_id: CERT_MNGR_VERIFICATION_APPROVE,
                                         project_role: ProjectsUser.roles[:certifier_manager],
                                         project: self.scheme_mix.certification_path.project,
                                         certification_path: self.scheme_mix.certification_path)
          end
          # Destroy certifier member tasks to verify criterion
          SchemeMixCriterionTask.delete_all(task_description_id: CERT_MEM_VERIFY, scheme_mix_criterion: self)
      end
    end
  end

  def handle_criterion_assignment_changed
    if self.certifier_id_changed?
      # Can a criterion be assigned to nil ?
      if self.certifier_id.nil?
        # Create certifier manager task to assign certifier to the criterion
        # SchemeMixCriterionTask.create(task_description_id: CERT_MNGR_ASSIGN,
        #                               project_role: ProjectsUser.roles[:certifier_manager],
        #                               project: self.scheme_mix.certification_path.project,
        #                               scheme_mix_criterion: self)
        if CertificationPathTask.find_by(task_description_id: CERT_MNGR_ASSIGN, certification_path: self.scheme_mix.certification_path).nil?
          CertificationPathTask.create(task_description_id: CERT_MNGR_ASSIGN,
                                       project_role: ProjectsUser.roles[:certifier_manager],
                                       project: self.scheme_mix.certification_path.project,
                                       certification_path: self.scheme_mix.certification_path)
        end
        # Destroy all certifier team member tasks to verify the criterion
        SchemeMixCriterionTask.delete_all(task_description_id: CERT_MEM_VERIFY, scheme_mix_criterion: self)
      else
        # Destroy all certifier team member tasks to verify the criterion which are assigned to another user
        SchemeMixCriterionTask.delete_all(task_description_id: CERT_MEM_VERIFY, scheme_mix_criterion: self)
        if [SchemeMixCriterion.statuses[:verifying], SchemeMixCriterion.statuses[:verifying_after_appeal]].include?(SchemeMixCriterion.statuses[self.status])
          # Create certifier team member task to screen the criterion
          SchemeMixCriterionTask.create(task_description_id: CERT_MEM_VERIFY,
                                        user: self.certifier,
                                        project: self.scheme_mix.certification_path.project,
                                        scheme_mix_criterion: self)
        end
        # Destroy all certifier manager tasks to assign certifier team member to this criterion
        # SchemeMixCriterionTask.delete_all(task_description_id: CERT_MNGR_ASSIGN, scheme_mix_criterion: self)
        if self.scheme_mix.certification_path.scheme_mix_criteria.unassigned.where(status: [SchemeMixCriterion.statuses[:verifying], SchemeMixCriterion.statuses[:verifying_afer_appeal]]).count.zero?
          CertificationPathTask.delete_all(task_description_id: CERT_MNGR_ASSIGN, certification_path: self.scheme_mix.certification_path)
        end
      end
    end
  end

  def handle_updated_requirement_datum
    handle_requirement_status_changed
    handle_requirement_assignment_changed
  end

  def handle_requirement_status_changed
    if self.status_changed?
      case RequirementDatum.statuses[self.status]
        # Can requirement status be reset to 'required' ?
        when RequirementDatum.statuses[:required]
          if self.user.nil?
            if self.scheme_mix_criteria.first.submitting?
              # Create project manager task to assign a project team member to the requirement
              # RequirementDatumTask.create(task_description_id: PROJ_MNGR_ASSIGN,
              #                             project_role: ProjectsUser.roles[:project_manager],
              #                             project: self.scheme_mix_criteria.first.scheme_mix.certification_path.project,
              #                             requirement_datum: self)
              if CertificationPathTask.find_by(task_description_id: PROJ_MNGR_ASSIGN, certification_path: self.scheme_mix_criteria.first.scheme_mix.certification_path).nil?
                CertificationPathTask.create(task_description_id: PROJ_MNGR_ASSIGN,
                                             project_role: ProjectsUser.roles[:project_manager],
                                             project: self.scheme_mix_criteria.first.scheme_mix.certification_path.project,
                                             certification_path: self.scheme_mix_criteria.first.scheme_mix.certification_path)
              end
            elsif self.scheme_mix_criteria.first.submitting_after_appeal?
              # Create project manager task to assign a project team member to the requirement
              # RequirementDatumTask.create(task_description_id: PROJ_MNGR_ASSIGN_AFTER_APPEAL,
              #                             project_role: ProjectsUser.roles[:project_manager],
              #                             project: self.scheme_mix_criteria.first.scheme_mix.certification_path.project,
              #                             requirement_datum: self)
              if CertificationPathTask.find_by(task_description_id: PROJ_MNGR_ASSIGN_AFTER_APPEAL, certification_path: self.scheme_mix_criteria.first.scheme_mix.certification_path).nil?
                CertificationPathTask.create(task_description_id: PROJ_MNGR_ASSIGN_AFTER_APPEAL,
                                             project_role: ProjectsUser.roles[:project_manager],
                                             project: self.scheme_mix_criteria.first.scheme_mix.certification_path.project,
                                             certification_path: self.scheme_mix_criteria.first.scheme_mix.certification_path)
              end
            end
          else
            # Create project team member task to provide the requirement
            RequirementDatumTask.create(task_description_id: PROJ_MEM_REQ,
                                        user: self.user,
                                        project: self.scheme_mix_criteria.first.scheme_mix.certification_path.project,
                                        requirement_datum: self)
          end
          # Destroy project manager tasks to set criterion status to complete
          SchemeMixCriterionTask.delete_all(task_description_id: PROJ_MNGR_CRIT_APPROVE,
                                            project_role: ProjectsUser.roles[:project_manager],
                                            project: self.scheme_mix_criteria.first.scheme_mix.certification_path.project,
                                            requirement_datum_id: self.id)
        when RequirementDatum.statuses[:provided], RequirementDatum.statuses[:not_required]
          # Check if criterion with status 'submitting'/'submitting after appeal' has no linked requirements in status 'required'
          if SchemeMixCriterion.joins(:scheme_mix_criteria_requirement_data)
                     .where(id: self.scheme_mix_criteria.first.id, status: [SchemeMixCriterion.statuses[:submitting],SchemeMixCriterion.statuses[:submitting_after_appeal]])
                     .where.not('exists(select rd.id from requirement_data rd inner join scheme_mix_criteria_requirement_data smcrd on smcrd.requirement_datum_id = rd.id where smcrd.scheme_mix_criterion_id = scheme_mix_criteria.id and rd.status = ?)', RequirementDatum.statuses[:required])
                     .count.nonzero?
            # Create project manager task to set criterion status to complete
            SchemeMixCriterionTask.create(task_description_id: PROJ_MNGR_CRIT_APPROVE,
                                          project_role: ProjectsUser.roles[:project_manager],
                                          project: self.scheme_mix_criteria.first.scheme_mix.certification_path.project,
                                          scheme_mix_criterion: self.scheme_mix_criteria.first)
          end
          # Destroy project manager tasks to assign project team members to requirement and project team member tasks to provide the requirement
          # RequirementDatumTask.delete_all(task_description_id: [PROJ_MNGR_ASSIGN, PROJ_MNGR_ASSIGN_AFTER_APPEAL, PROJ_MEM_REQ], requirement_datum_id: self.id)
          RequirementDatumTask.delete_all(task_description_id: PROJ_MEM_REQ, requirement_datum_id: self.id)
          if self.scheme_mix_criteria.first.scheme_mix.certification_path.requirement_data.unassigned.where(status: RequirementDatum.statuses[:required]).count.zero?
            CertificationPathTask.delete_all(task_description_id: [PROJ_MNGR_ASSIGN, PROJ_MNGR_ASSIGN_AFTER_APPEAL], certification_path: self.scheme_mix_criteria.first.scheme_mix.certification_path)
          end
      end
    end
  end

  def handle_requirement_assignment_changed
    if self.user_id_changed?
      # Can a requirement be assigned to nil ?
      if self.user_id.nil?
        if RequirementDatum.statuses[self.status] == RequirementDatum.statuses[:required]
          if self.scheme_mix_criteria.first.submitting?
            # Create project manager task to assign project team member
            # RequirementDatumTask.create(task_description_id: PROJ_MNGR_ASSIGN,
            #                             project_role: ProjectsUser.roles[:project_manager],
            #                             project: self.scheme_mix_criteria.first.scheme_mix.certification_path.project,
            #                             requirement_datum: self)
            if CertificationPathTask.find_by(task_description_id: PROJ_MNGR_ASSIGN, certification_path: self.scheme_mix_criteria.first.scheme_mix.certification_path).nil?
              CertificationPathTask.create(task_description_id: PROJ_MNGR_ASSIGN,
                                           project_role: ProjectsUser.roles[:project_manager],
                                           project: self.scheme_mix_criteria.first.scheme_mix.certification_path.project,
                                           certification_path: self.scheme_mix_criteria.first.scheme_mix.certification_path)
            end
          elsif self.scheme_mix_criteria.first.submitting_after_appeal?
            # Create project manager task to assign project team member
            # RequirementDatumTask.create(task_description_id: PROJ_MNGR_ASSIGN_AFTER_APPEAL,
            #                             project_role: ProjectsUser.roles[:project_manager],
            #                             project: self.scheme_mix_criteria.first.scheme_mix.certification_path.project,
            #                             requirement_datum: self)
            if CertificationPathTask.find_by(task_description_id: PROJ_MNGR_ASSIGN_AFTER_APPEAL, certification_path: self.scheme_mix_criteria.first.scheme_mix.certification_path).nil?
              CertificationPathTask.create(task_description_id: PROJ_MNGR_ASSIGN_AFTER_APPEAL,
                                           project_role: ProjectsUser.roles[:project_manager],
                                           project: self.scheme_mix_criteria.first.scheme_mix.certification_path.project,
                                           certification_path: self.scheme_mix_criteria.first.scheme_mix.certification_path)
            end
          end
        end
        # Destroy project team member tasks to provide the requirement
        RequirementDatumTask.delete_all(task_description_id: PROJ_MEM_REQ, requirement_datum_id: self.id)
      else
        # Destroy project team member tasks to provide the requirement (which are assigned to another user)
        RequirementDatumTask.delete_all(task_description_id: PROJ_MEM_REQ, requirement_datum_id: self.id)
        if RequirementDatum.statuses[self.status] == RequirementDatum.statuses[:required]
          if self.scheme_mix_criteria.first.scheme_mix.certification_path.in_submission?
            # Create project team member task to provide the requirement
            RequirementDatumTask.create(task_description_id: PROJ_MEM_REQ,
                                        user: self.user,
                                        project: self.scheme_mix_criteria.first.scheme_mix.certification_path.project,
                                        requirement_datum: self)
          end
        end
        # Destroy project manager tasks to assign project team member
        # RequirementDatumTask.delete_all(task_description_id: [PROJ_MNGR_ASSIGN, PROJ_MNGR_ASSIGN_AFTER_APPEAL], requirement_datum_id: self.id)
        if self.scheme_mix_criteria.first.scheme_mix.certification_path.requirement_data.unassigned.where(status: RequirementDatum.statuses[:required]).count.zero?
          CertificationPathTask.delete_all(task_description_id: [PROJ_MNGR_ASSIGN, PROJ_MNGR_ASSIGN_AFTER_APPEAL], certification_path: self.scheme_mix_criteria.first.scheme_mix.certification_path)
        end
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
          SchemeMixCriterionDocumentTask.create(task_description_id: PROJ_MNGR_DOC_APPROVE,
                                                project_role: ProjectsUser.roles[:project_manager],
                                                project: self.scheme_mix_criterion.scheme_mix.certification_path.project,
                                                scheme_mix_criteria_document: self)
        when SchemeMixCriteriaDocument.statuses[:approved], SchemeMixCriteriaDocument.statuses[:rejected], SchemeMixCriteriaDocument.statuses[:superseded]
          # Destroy project managers tasks to approve/reject document
          SchemeMixCriterionDocumentTask.delete_all(task_description_id: PROJ_MNGR_DOC_APPROVE, scheme_mix_criteria_document: self)
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
          # certification_path.requirement_data.unassigned.required.where.not('exists(select tasks.id from tasks where tasks.requirement_datum_id = requirement_data.id and tasks.task_description_id = ?)', PROJ_MNGR_ASSIGN).each do |requirement_datum|
          #   RequirementDatumTask.create(task_description_id: PROJ_MNGR_ASSIGN,
          #                               project_role: ProjectsUser.roles[:project_manager],
          #                               project: self.project,
          #                               requirement_datum: requirement_datum)
          # end
          if CertificationPathTask.find_by(task_description_id: PROJ_MNGR_ASSIGN, certification_path: certification_path).nil?
            if certification_path.requirement_data.unassigned.required.count.nonzero?
              CertificationPathTask.create(task_description_id: PROJ_MNGR_ASSIGN,
                                           project_role: ProjectsUser.roles[:project_manager],
                                           project: self.project,
                                           certification_path: certification_path)
            end
          end
        end
        project.certification_paths.with_status(CertificationPathStatus::SUBMITTING_AFTER_APPEAL).each do |certification_path|
          # certification_path.requirement_data.unassigned.required.where.not('exists(select tasks.id from tasks where tasks.requirement_datum_id = requirement_data.id and tasks.task_description_id = ?)', PROJ_MNGR_ASSIGN_AFTER_APPEAL).each do |requirement_datum|
          #   RequirementDatumTask.create(task_description_id: PROJ_MNGR_ASSIGN_AFTER_APPEAL,
          #                               project_role: ProjectsUser.roles[:project_manager],
          #                               project: self.project,
          #                               requirement_datum: requirement_datum)
          # end
          if CertificationPathTask.find_by(task_description_id: PROJ_MNGR_ASSIGN_AFTER_APPEAL, certification_path: certification_path).nil?
            if certification_path.requirement_data.unassigned.required.count.nonzero?
              CertificationPathTask.create(task_description_id: PROJ_MNGR_ASSIGN_AFTER_APPEAL,
                                           project_role: ProjectsUser.roles[:project_manager],
                                           project: self.project,
                                           certification_path: certification_path)
            end
          end
        end
      # A certifier is unassigned from project
      when ProjectsUser.roles[:certifier]
        # Create certifier manager tasks to assign certifier to criteria
        project.certification_paths.each do |certification_path|
          certification_path.scheme_mix_criteria.unassigned.where.not('exists(select tasks.id from tasks where tasks.scheme_mix_criterion_id = scheme_mix_criteria.id and tasks.task_description_id = ?)', CERT_MNGR_ASSIGN).each do |scheme_mix_criterion|
            SchemeMixCriterionTask.create(task_description_id: CERT_MNGR_ASSIGN,
                                          project_role: ProjectsUser.roles[:certifier_manager],
                                          project: self.project,
                                          scheme_mix_criterion: scheme_mix_criterion)
          end
          if CertificationPathTask.find_by(task_description_id: CERT_MNGR_ASSIGN, certification_path: certification_path).nil?
            if certification_path.scheme_mix_criteria.unassigned.count.nonzero?
              CertificationPathTask.create(task_description_id: CERT_MNGR_ASSIGN,
                                           project_role: ProjectsUser.roles[:certifier_manager],
                                           project: self.project,
                                           certification_path: certification_path)
            end
          end
        end
      # A certifier manager is unassigned from project
      when ProjectsUser.roles[:certifier_manager]
        unless self.project.certifier_manager_assigned?
          # Create system admin task to assign a certifier manager
          ProjectTask.create(task_description_id: SYS_ADMIN_ASSIGN,
                             application_role: User.roles[:system_admin],
                             project: self.project)
        end
    end
  end

end