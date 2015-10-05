module Taskable
  extend ActiveSupport::Concern

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

  def handle_created_projects_user
    case ProjectsUser.roles[self.role]
      # Certifier manager is assigned to project
      when ProjectsUser.roles[:certifier_manager]
        # Destroy all system admin tasks to assign a certifier manager for this project
        CertificationPathTask.where(task_description_id: 1, project: self.project).each do |task|
          if task.certification_path.certification_path_status_id == CertificationPathStatus::ACTIVATING
            # Create system admin task to advance the certification path status
            CertificationPathTask.create(task_description_id: 2,
                                         application_role: User.roles[:system_admin],
                                         project: task.project,
                                         certification_path: task.certification_path)
          end
          task.destroy
        end
    end
  end

  def handle_created_certification_path
    unless self.project.certifier_manager_assigned?
      # Create system admin task to assign a certifier manager and advance the certification path status
      CertificationPathTask.create(task_description_id: 1,
                                   application_role: User.roles[:system_admin],
                                   project: self.project,
                                   certification_path: self)
    else
      # Create system admin task to advance the certification path status
      CertificationPathTask.create(task_description_id: 2,
                                   application_role: User.roles[:system_admin],
                                   project: self.project,
                                   certification_path: self)
    end
  end

  def handle_created_scheme_mix_criteria_document
    # Create project manager task to approve/reject document
    SchemeMixCriterionDocumentTask.create(task_description_id: 29,
                                          project_role: ProjectsUser.roles[:project_manager],
                                          project: self.scheme_mix_criterion.scheme_mix.certification_path.project,
                                          scheme_mix_criteria_document: self)
  end

  def handle_updated_projects_user
    if self.role_changed?
      # TODO ? unassign project team members from requirement tasks
      # TODO ? unassign certifiers from criteria tasks
      leave_role(self.role_was, self.user, self.project)
      case ProjectsUser.roles[self.role]
        # A user with access to the project is now certifier manager
        when ProjectsUser.roles[:certifier_manager]
          # Destroy all system admin tasks to assign a certifier manager for this project
          CertificationPathTask.where(task_description_id: 1, project: self.project).each do |task|
            # Create system admin task to advance the certification path status
            CertificationPathTask.create(task_description_id: 2,
                                         application_role: User.roles[:system_admin],
                                         project: task.project,
                                         certification_path: task.certification_path)
            task.destroy
          end
        else
      end
    end
  end

  def handle_updated_certification_path
    if self.certification_path_status_id_changed?
      case self.certification_path_status_id
        when CertificationPathStatus::ACTIVATING
        when CertificationPathStatus::SUBMITTING
          # Create project manager tasks to assign project team members to requirements
          self.requirement_data.unassigned.required.each do |requirement_datum|
            RequirementDatumTask.create(task_description_id: 3,
                                        project_role: ProjectsUser.roles[:project_manager],
                                        project: self.project,
                                        requirement_datum: requirement_datum)
          end
          # Destroy all system admin tasks to advance the certification path status
          CertificationPathTask.delete_all(task_description_id: 2, certification_path: self)
        when CertificationPathStatus::SCREENING
          # Create certifier manager tasks to assign certifier team members to criteria
          self.scheme_mix_criteria.unassigned.complete.each do |scheme_mix_criterion|
            SchemeMixCriterionTask.create(task_description_id: 7,
                                          project_role: ProjectsUser.roles[:certifier_manager],
                                          project: self.project,
                                          scheme_mix_criterion: scheme_mix_criterion)
          end
          # Destroy project manager tasks to advance certification path status
          CertificationPathTask.delete_all(task_description_id: 6, certification_path: self)
        when CertificationPathStatus::SUBMITTING_AFTER_SCREENING
          # SPECIAL CASE !!!
          # Create project manager task to process screening comments
          CertificationPathTask.create(task_description_id: 10,
                                       project_role: ProjectsUser.roles[:project_manager],
                                       project: self.project,
                                       certification_path: self)
          # Destroy all certifier manager tasks to advance status
          CertificationPathTask.delete_all(task_description_id: 9, certification_path: self)
          self.scheme_mix_criteria.each do |criterion|
            # Destroy all certifier team member tasks to screen criteria
            SchemeMixCriterionTask.delete_all(task_description_id: 8, scheme_mix_criterion: criterion)
          end
        when CertificationPathStatus::PROCESSING_PCR_PAYMENT
          # Destroy all project manager tasks to process screening comments
          CertificationPathTask.delete_all(task_description_id: 10, certification_path: self)
        when CertificationPathStatus::SUBMITTING_PCR
          # SPECIAL CASE !!!
          # Create project manager task to advance status
          CertificationPathTask.create(task_description_id: 15,
                                       project_role: ProjectsUser.roles[:project_manager],
                                       project: self.project,
                                       certification_path: self)
          # Create certifier team member task to review criteria (together with project manager?)
          self.scheme_mix_criteria.each do |scheme_mix_criterion|
            SchemeMixCriterionTask.create(task_description_id: 8,
                                          user: scheme_mix_criterion.certifier,
                                          project: self.project,
                                          scheme_mix_criterion: scheme_mix_criterion)
          end
          # Destroy all system admin tasks to advance the certification path status
          CertificationPathTask.delete_all(task_description_id: 12, certification_path: self)
        when CertificationPathStatus::VERIFYING
          # SPECIAL CASE !!!
          # Create certifier team member task to verify criteria
          self.scheme_mix_criteria.each do |scheme_mix_criterion|
            SchemeMixCriterionTask.create(task_description_id: 16,
                                          user: scheme_mix_criterion.certifier,
                                          project: self.project,
                                          scheme_mix_criterion: scheme_mix_criterion)
          end
          # Destroy certifier team member tasks to review criteria
          self.scheme_mix_criteria.each do |scheme_mix_criterion|
            SchemeMixCriterionTask.where(task_description_id: 8, scheme_mix_criterion: scheme_mix_criterion)
          end
          # Destroy project manager tasks to advance status
          CertificationPathTask.delete_all(task_description_id: 15, certification_path: self)
        when CertificationPathStatus::ACKNOWLEDGING
          # Create project manager task to process verification comments
          CertificationPathTask.create(task_description_id: 10,
                                       project_role: ProjectsUser.roles[:project_manager],
                                       project: self.project,
                                       certification_path: self)
          # Destroy all certifier manager tasks to advance status
          CertificationPathTask.delete_all(task_description_id: 17, certification_path: self)
        when CertificationPathStatus::PROCESSING_APPEAL_PAYMENT
          # Create system admin task to check appeal payment
          CertificationPathTask.create(task_description_id: 19,
                                       application_role: User.roles[:system_admin],
                                       project: self.project,
                                       certification_path: self)
          # Destroy all project manager tasks to process verification comments
          CertificationPathTask.delete_all(task_description_id: 10, certification_path: self)
        when CertificationPathStatus::SUBMITTING_AFTER_APPEAL
          # Create project team members tasks to provide requirements
          self.requirement_data.where.not(user: nil).required.each do |requirement_datum|
            RequirementDatumTask.create(task_description_id: 4,
                                        user: requirement_datum.user,
                                        project: self.project,
                                        requirement_datum: requirement_datum)
          end
          # Destroy system admin tasks to check appeal payment
          CertificationPathTask.delete_all(task_description_id: 19, certification_path: self)
        when CertificationPathStatus::VERIFYING_AFTER_APPEAL
          # Create certifiers tasks to verify criteria
          self.scheme_mix_criteria.each do |scheme_mix_criterion|
            SchemeMixCriterionTask.create(task_description_id: 16,
                                          user: scheme_mix_criterion.certifier,
                                          project: self.project,
                                          scheme_mix_criterion: scheme_mix_criterion)
          end
          # Destroy project manager tasks to advance certification path status
          CertificationPathTask.delete_all(task_description_id: 6, certification_path: self)
        when CertificationPathStatus::ACKNOWLEDGING_AFTER_APPEAL
          # Create project manager task to process verification comments
          CertificationPathTask.create(task_description_id: 10,
                                       project_role: ProjectsUser.roles[:project_manager],
                                       project: self.project,
                                       certification_path: self)
          # Destroy all certifier manager tasks to advance status
          CertificationPathTask.delete_all(task_description_id: 17, certification_path: self)
        when CertificationPathStatus::APPROVING_BY_MANAGEMENT
          # Create task for GORD manager to quick check and approve
          CertificationPathTask.create(task_description_id: 25,
                                       application_role: User.roles[:gord_manager],
                                       project: self.project,
                                       certification_path: self)
          # Destroy all project manager tasks to process verification comments
          CertificationPathTask.delete_all(task_description_id: 10, certification_path: self)
        when CertificationPathStatus::CERTIFIED
          # Create project manager task to download certificate
          CertificationPathTask.create(task_description_id: 28,
                                       project_role: ProjectsUser.roles[:project_manager],
                                       project: self.project,
                                       certification_path: self)
          # Destroy all gord top manager tasks to advance certification path status
          CertificationPathTask.delete_all(task_description_id: 27, certification_path: self)
        when CertificationPathStatus::NOT_CERTIFIED
          # Destroy all project manager tasks to process verification comments
          CertificationPathTask.delete_all(task_description_id: 10, certification_path: self)
      end
    end
    handle_pcr_track
    handle_pcr_track_allowed
    handle_signed_by_gord_mngr
    handle_signed_by_gord_top_mngr
  end

  def handle_updated_scheme_mix_criterion
    if self.status_changed?
      case SchemeMixCriterion.statuses[self.status]
        when SchemeMixCriterion.statuses[:complete]
          # Test if no criteria with status 'in progress' are still linked to certification path in status 'submitting'
          if CertificationPath.joins(:scheme_mixes)
                 .where(id: self.scheme_mix.certification_path.id, certification_path_status_id: CertificationPathStatus::SUBMITTING)
                 .where.not('exists(select smc.id from scheme_mix_criteria smc where smc.scheme_mix_id = scheme_mixes.id and smc.status = 0)')
                 .count.nonzero?
            # Create project manager task to advance certification path status
            CertificationPathTask.create(task_description_id: 6,
                                         project_role: ProjectsUser.roles[:project_manager],
                                         project: self.scheme_mix.certification_path.project,
                                         certification_path: self.scheme_mix.certification_path)
          end
          # Destroy project manager tasks to set criterion status to complete
          SchemeMixCriterionTask.delete_all(task_description_id: 5, scheme_mix_criterion: self)
        when SchemeMixCriterion.statuses[:approved], SchemeMixCriterion.statuses[:resubmit]
          # Test if no criteria with status 'complete' are still linked to certification path in status 'verifying'
          if CertificationPath.joins(:scheme_mixes)
                 .where(id: self.scheme_mix.certification_path.id, certification_path_status_id: CertificationPathStatus::VERIFYING)
                 .where.not('exists(select smc.id from scheme_mix_criteria smc where smc.scheme_mix_id = scheme_mixes.id and smc.status = 1)')
                 .count.nonzero?
            # Create certifier manager task to advance certification path status
            CertificationPathTask.create(task_description_id: 17,
                                         project_role: ProjectsUser.roles[:certifier_manager],
                                         project: self.scheme_mix.certification_path.project,
                                         certification_path: self.scheme_mix.certification_path)
          end
          # Destroy certifier team member tasks to verify criteria
          SchemeMixCriterionTask.delete_all(task_description_id: 16, scheme_mix_criterion: self)
      end
    end
    # A/another certifier is assigned to the criterion
    if self.certifier_id_changed?
      if self.complete?
        # Create certifier team member task to screen the criterion
        SchemeMixCriterionTask.create(task_description_id: 8,
                                      user: self.certifier,
                                      project: self.scheme_mix.certification_path.project,
                                      scheme_mix_criterion: self)
        # Destroy all certifier manager tasks to assign certifier team member to this criterion
        SchemeMixCriterionTask.delete_all(task_description_id: 7, scheme_mix_criterion: self)
        # Destroy all certifier team member tasks to screen the criterion which are assigned to another user
        SchemeMixCriterionTask.where.not(user: self.certifier).delete_all(task_description_id: 8, scheme_mix_criterion: self)
        if CertificationPathTask.where(task_description_id: 9, certification_path: self.scheme_mix.certification_path).blank?
          # Create certifier manager task to advance certificate path status
          CertificationPathTask.create(task_description_id: 9,
                                       project_role: ProjectsUser.roles[:certifier_manager],
                                       certification_path: self.scheme_mix.certification_path)
        end
      end
    end
  end

  def handle_updated_requirement_datum
    if self.status_changed?
      if self.provided? or self.not_required?
        # Test if no requirements with status 'required' are still linked to criterion in status 'in progress'
        if SchemeMixCriterion.joins(:scheme_mix_criteria_requirement_data)
               .where(id: self.scheme_mix_criteria.first.id, status: 0)
               .where.not('exists(select rd.id from requirement_data rd where rd.id = scheme_mix_criteria_requirement_data.requirement_datum_id and rd.status = 0)')
               .count.nonzero?
          # Create project manager task to set criterion status to complete
          SchemeMixCriterionTask.create(task_description_id: 5,
                                        project_role: ProjectsUser.roles[:project_manager],
                                        project: self.scheme_mix_criteria.first.scheme_mix.certification_path.project,
                                        scheme_mix_criterion: self.scheme_mix_criteria.first)
        end
        # Destroy project team member tasks to provide the requirement
        RequirementDatumTask.delete_all(task_description_id: 4, requirement_datum: self)
      end
    end
    # A/another project team member is assigned to the requirement
    if self.user_id_changed?
      if self.required?
        # Create project team member task to provide the requirement
        RequirementDatumTask.create(task_description_id: 4,
                                    user: self.user,
                                    project: self.scheme_mix_criteria.first.scheme_mix.certification_path.project,
                                    requirement_datum: self)
        # Destroy all project manager tasks to assign project team member
        RequirementDatumTask.delete_all(task_description_id: 3, requirement_datum: self)
        # Destroy all project team member tasks to provide the requirement which are assigned to another user
        RequirementDatumTask.where.not(user: self.user).delete_all(task_description_id: 4, requirement_datum: self)
      end
    end

  end

  def handle_updated_scheme_mix_criteria_document
    if self.status_changed?
      # Destroy all project managers tasks to approve/reject document
      SchemeMixCriterionDocumentTask.delete_all(task_description_id: 29, scheme_mix_criteria_document: self)
    end
  end

  def handle_destroyed_projects_user
    leave_role(self.role, self.user, self.project)
  end

  def leave_role(role, user, project)
    project.certification_paths.each do |certification_path|
      case certification_path.certification_path_status_id
        when CertificationPathStatus::SUBMITTING, CertificationPathStatus::SUBMITTING_AFTER_APPEAL
          # get all required unassigned requirements for this certificate and with no task 3
          certification_path.requirement_data.unassigned.required.where.not('exists(select tasks.id from tasks where tasks.requirement_datum_id = requirement_data.id)').each do |requirement_datum|
            RequirementDatumTask.create(task_description_id: 3,
                                        project_role: ProjectsUser.roles[:project_manager],
                                        project: self.project,
                                        requirement_datum: requirement_datum)
          end
      end
    end
    # TODO create certifier manager tasks
    case ProjectsUser.roles[role]
      when ProjectsUser.roles[:certifier_manager]
        unless self.project.certifier_manager_assigned?
          self.project.certification_paths.each do |certification_path|
            # Create system admin task to assign a certifier manager
            CertificationPathTask.create(task_description_id: 1,
                                         application_role: User.roles[:system_admin],
                                         project: certification_path.project,
                                         certification_path: certification_path)
          end
        end
    end
  end

  def handle_pcr_track
    if self.pcr_track_changed?
      if self.pcr_track == true
        if self.pcr_track_allowed == false and self.certification_path_status_id < CertificationPathStatus::PROCESSING_PCR_PAYMENT
          # Create system admin task to check PCR payment
          CertificationPathTask.create(task_description_id: 11,
                                       application_role: User.roles[:system_admin],
                                       project: self.project,
                                       certification_path: self)
        end
      elsif self.pcr_track_allowed == false and self.certification_path_status_id < CertificationPathStatus::PROCESSING_PCR_PAYMENT
        CertificationPathTask.delete_all(task_description_id: 11, certification_path: self)
      end
    end
  end

  def handle_pcr_track_allowed
    if self.pcr_track_allowed_changed?
      if self.pcr_track_allowed == true
        if self.pcr_track == true and self.certification_path_status_id < CertificationPathStatus::PROCESSING_PCR_PAYMENT
          # Create system admin task to advance the certification path status
          CertificationPathTask.create(task_description_id: 12,
                                       application_role: User.roles[:system_admin],
                                       project: self.project,
                                       certification_path: self)
          # Destroy system admin tasks to check PCR payment
          CertificationPathTask.delete_all(task_description_id: 11, certification_path: self)
        end
      elsif self.pcr_track == true and self.certification_path_status_id < CertificationPathStatus::PROCESSING_PCR_PAYMENT
        CertificationPathTask.create(task_description_id: 11,
                                     application_role: User.roles[:system_admin],
                                     project: self.project,
                                     certification_path: self)
        CertificationPathTask.delete_all(task_description_id: 12, certification_path: self)
      end
    end
  end

  def handle_signed_by_gord_mngr
    if self.signed_by_mngr_changed?
      if self.signed_by_mngr == true
        if self.signed_by_top_mngr == false and self.certification_path_status_id == CertificationPathStatus::APPROVING_BY_MANAGEMENT
          # Create GORD top manager task to approve
          CertificationPathTask.create(task_description_id: 26,
                                       application_role: User.roles[:gord_top_manager],
                                       project: self.project,
                                       certification_path: self)
          # Destroy all GORD manager tasks to check and approve certificate
          CertificationPathTask.delete_all(task_description_id: 25, certification_path: self)
        end
      elsif self.signed_by_top_mngr == false and self.certification_path_status_id == CertificationPathStatus::APPROVING_BY_MANAGEMENT
        CertificationPathTask.create(task_description_id: 25,
                                     application_role: User.role[:gord_manager],
                                     project: self.project,
                                     certification_path: self)
        CertificationPathTask.delete_all(task_description_id: 26, certification_path: self)
      end
    end
  end

  def handle_signed_by_gord_top_mngr
    if self.signed_by_top_mngr_changed?
      if self.signed_by_top_mngr == true
        if self.signed_by_mngr == true and self.certification_path_status_id == CertificationPathStatus::APPROVING_BY_MANAGEMENT
          # Create GORD top manager task to advance certification path status
          CertificationPathTask.create(task_description_id: 27,
                                       application_role: User.roles[:gord_top_manager],
                                       project: self.project,
                                       certification_path: self)
          # Destroy all GORD top manager tasks to approve certificate
          CertificationPathTask.delete_all(task_description_id: 26, certification_path: self)
        end
      elsif self.signed_by_mngr == true and self.certification_path_status_id == CertificationPathStatus::APPROVING_BY_MANAGEMENT
        CertificationPathTask.create(task_description_id: 26,
                                     application_role: User.roles[:gord_top_manager],
                                     project: self.project,
                                     certification_path: self)
        CertificationPathTask.delete_all(task_description_id: 27, certification_path: self)
      end
    end
  end

end