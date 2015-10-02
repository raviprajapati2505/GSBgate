module Taskable
  extend ActiveSupport::Concern

  included do
    after_create :after_create
    after_update :after_update
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

  def after_destroy
    case self.class.name
      when ProjectsUser.name.demodulize
        handle_destroyed_projects_user
    end
  end

  def handle_created_projects_user
    case self.role
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
      case self.role
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
          unless self.project.certifier_manager_assigned?
            self.project.certification_paths.each do |certification_path|
              # Create system admin task to advance the certification path status
              CertificationPathTask.create(task_description_id: 1,
                                           application_role: User.roles[:system_admin],
                                           project: certification_path.project,
                                           certification_path: certification_path)
            end
          end
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
          CertificationPathTask.where(task_description_id: 2, certification_path: self).each do |task|
            task.destroy
          end
        when CertificationPathStatus::SCREENING
          # Create certifier manager tasks to assign certifier team members to criteria
          self.scheme_mix_criteria.unassigned.complete.each do |scheme_mix_criterion|
            SchemeMixCriterionTask.create(task_description_id: 7,
                                          project_role: ProjectsUser.roles[:certifier_manager],
                                          project: self.project,
                                          scheme_mix_criterion: scheme_mix_criterion)
          end
          # Destroy project manager tasks to advance certification path status
          CertificationPathTask.where(task_description_id: 6, certification_path: self).each do |task|
            task.destroy
          end
        when CertificationPathStatus::SUBMITTING_AFTER_SCREENING
          # SPECIAL CASE !!!
          # Create project manager task to process screening comments
          CertificationPathTask.create(task_description_id: 10,
                                       project_role: ProjectsUser.roles[:project_manager],
                                       project: self.project,
                                       certification_path: self)
          # Destroy all certifier manager tasks to advance status
          CertificationPathTask.where(task_description_id: 9, certification_path: self).each do |task|
            task.destroy
          end
          self.scheme_mix_criteria.each do |criterion|
            # Destroy all certifier team member tasks to screen criteria
            SchemeMixCriterionTask.where(task_description_id: 8, scheme_mix_criterion: criterion).each do |task|
              task.destroy
            end
          end
        when CertificationPathStatus::PROCESSING_PCR_PAYMENT
          # Destroy all project manager tasks to process screening comments
          CertificationPathTask.where(task_description_id: 10, certification_path: self).each do |task|
            task.destroy
          end
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
          CertificationPathTask.where(task_description_id: 12, certification_path: self).each do |task|
            task.destroy
          end
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
          CertificationPathTask.where(task_description_id: 15, certification_path: self).each do |task|
            task.destroy
          end
        when CertificationPathStatus::ACKNOWLEDGING
          # Create project manager task to process verification comments
          CertificationPathTask.create(task_description_id: 10,
                                       project_role: ProjectsUser.roles[:project_manager],
                                       project: self.project,
                                       certification_path: self)
          # Destroy all certifier manager tasks to advance status
          CertificationPathTask.where(task_description_id: 17, certification_path: self).each do |task|
            task.destroy
          end
        when CertificationPathStatus::PROCESSING_APPEAL_PAYMENT
          # Create system admin task to check appeal payment
          CertificationPathTask.create(task_description_id: 19,
                                       application_role: User.roles[:system_admin],
                                       project: self.project,
                                       certification_path: self)
          # Destroy all project manager tasks to process verification comments
          CertificationPathTask.where(task_description_id: 10, certification_path: self).each do |task|
            task.destroy
          end
        when CertificationPathStatus::SUBMITTING_AFTER_APPEAL
          # Create project team members tasks to provide requirements
          self.requirement_data.required.each do |requirement_datum|
            RequirementDatumTask.create(task_description_id: 4,
                                        user: requirement_datum.user,
                                        project: self.project,
                                        requirement_datum: requirement_datum)
          end
          # Destroy system admin tasks to check appeal payment
          CertificationPathTask.where(task_description_id: 19, certification_path: self).each do |task|
            task.destroy
          end
        when CertificationPathStatus::VERIFYING_AFTER_APPEAL
          # Create certifiers tasks to verify criteria
          self.scheme_mix_criteria.each do |scheme_mix_criterion|
            SchemeMixCriterionTask.create(task_description_id: 16,
                                          user: scheme_mix_criterion.certifier,
                                          project: self.project,
                                          scheme_mix_criterion: scheme_mix_criterion)
          end
          # Destroy project manager tasks to advance certification path status
          CertificationPathTask.where(task_description_id: 6, certification_path: self).each do |task|
            task.destroy
          end
        when CertificationPathStatus::ACKNOWLEDGING_AFTER_APPEAL
          # Create project manager task to process verification comments
          CertificationPathTask.create(task_description_id: 10,
                                       project_role: ProjectsUser.roles[:project_manager],
                                       project: self.project,
                                       certification_path: self)
          # Destroy all certifier manager tasks to advance status
          CertificationPathTask.where(task_description_id: 17, certification_path: self).each do |task|
            task.destroy
          end
        when CertificationPathStatus::APPROVING_BY_MANAGEMENT
          # Create task for GORD manager to quick check and approve
          CertificationPathTask.create(task_description_id: 25,
                                       application_role: User.roles[:gord_manager],
                                       project: self.project,
                                       certification_path: self)
          # Destroy all project manager tasks to process verification comments
          CertificationPathTask.where(task_description_id: 10, certification_path: self).each do |task|
            task.destroy
          end
        when CertificationPathStatus::CERTIFIED
          # Create project manager task to download certificate
          CertificationPathTask.create(task_description_id: 28,
                                       project_role: ProjectsUser.roles[:project_manager],
                                       project: self.project,
                                       certification_path: self)
          # Destroy all gord top manager tasks to advance certification path status
          CertificationPathTask.where(task_description_id: 27, certification_path: self).each do |task|
            task.destroy
          end
        when CertificationPathStatus::NOT_CERTIFIED
          # Destroy all project manager tasks to process verification comments
          CertificationPathTask.where(task_description_id: 10, certification_path: self).each do |task|
            task.destroy
          end
      end
    end
    handle_pcr_track
    handle_pcr_track_allowed
    handle_signed_by_gord_mngr
    handle_signed_by_gord_top_mngr
  end

  def handle_updated_scheme_mix_criterion
    if self.status_changed?
      case self.status
        when SchemeMixCriterion.statuses[:complete]
          # Test if no criteria with status 'in progress' are still linked to certification path in status 'submitting'
          unless self.scheme_mix.certification_path.with_status(CertificationPathStatus::SUBMITTING).scheme_mix_criteria.in_progress.count.nonzero?
            # Create project manager task to advance certification path status
            CertificationPathTask.create(task_description_id: 6,
                                         project_role: ProjectsUser.roles[:project_manager],
                                         project: self.scheme_mix.certification_path.project,
                                         certification_path: self.scheme_mix.certification_path)
          end
          # Destroy project manager tasks to set criterion status to complete
          SchemeMixCriterion.where(task_description_id: 5, scheme_mix_criterion: self).each do |task|
            task.destroy
          end
        when SchemeMixCriterion.statuses[:approved], SchemeMixCriterion.statuses[:resubmit]
          # Test if no criteria with status 'complete' are still linked to certification path in status 'verifying'
          unless self.scheme_mix.certification_path.with_status(CertificationPathStatus::VERIFYING).scheme_mix_criteria.complete.count.nonzero?
            # Create certifier manager task to advance certification path status
            CertificationPathTask.create(task_description_id: 17,
                                         project_role: ProjectsUser.roles[:certifier_manager],
                                         project: self.scheme_mix.certification_path.project,
                                         certification_path: self.scheme_mix.certification_path)
          end
          # Destroy certifier team member tasks to verify criteria
          SchemeMixCriterionTask.where(task_description_id: 16, scheme_mix_criterion: self).each do |task|
            task.destroy
          end
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
        SchemeMixCriterionTask.where(task_description_id: 7, scheme_mix_criterion: self).each do |task|
          task.destroy
        end
        # Destroy all certifier team member tasks to screen the criterion which are assigned to another user
        SchemeMixCriterionTask.where(task_description_id: 8, scheme_mix_criterion: self).where.not(user: self.certifier).each do |task|
          task.destroy
        end
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
        unless self.scheme_mix_criteria.in_progress.requirement_data.required.count.nonzero?
          # Create project manager task to set criterion status to complete
          SchemeMixCriterionTask.create(task_description_id: 5,
                                        project_role: ProjectsUser.roles[:project_manager],
                                        project: self.scheme_mix_criteria.first.scheme_mix.certification_path.project,
                                        scheme_mix_criterion: self.scheme_mix_criteria.first)
        end
        # Destroy project team member tasks to provide the requirement
        RequirementDatumTask.where(task_description_id: 4, requirement_datum: self).each do |task|
          task.destroy
        end
      end
    end
    # A/another project team member is assigned to the requirement
    if self.user_id_changed?
      if self.required
        # Create project team member task to provide the requirement
        RequirementDatumTask.create(task_description_id: 4,
                                    user: self.user,
                                    project: self.scheme_mix_criteria.first.scheme_mix.certification_path.project,
                                    requirement_datum: self)
        # Destroy all project manager tasks to assign project team member
        RequirementDatumTask.where(task_description_id: 3, requirement_datum: self).each do |task|
          task.destroy
        end
        # Destroy all project team member tasks to provide the requirement which are assigned to another user
        RequirementDatumTask.where(task_description_id: 4, requirement_datum: self).where.not(user: self.user).each do |task|
          task.destroy
        end
      end
    end

  end

  def handle_updated_scheme_mix_criteria_document
    if self.status_changed?
      # Destroy all project managers tasks to approve/reject document
      SchemeMixCriterionDocumentTask.where(task_description_id: 29, scheme_mix_criteria_document: self).each do |task|
        task.destroy
      end
    end
  end

  def handle_destroyed_projects_user
    # TODO check if last certifier manager is unassigned and if true then create necessary tasks for system admin to re-assign new certifier manager
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
        CertificationPathTask.where(task_description_id: 11, certification_path: self).each do |task|
          task.destroy
        end
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
          CertificationPathTask.where(task_description_id: 11, certification_path: self).each do |task|
            task.destroy
          end
        end
      elsif self.pcr_track == true and self.certification_path_status_id < CertificationPathStatus::PROCESSING_PCR_PAYMENT
        CertificationPathTask.create(task_description_id: 11,
                                     application_role: User.roles[:system_admin],
                                     project: self.project,
                                     certification_path: self)
        CertificationPathTask.where(task_description_id: 12, certification_path: self).each do |task|
          task.destroy
        end
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
          CertificationPathTask.where(task_description_id: 25, certification_path: self).each do |task|
            task.destroy
          end
        end
      elsif self.signed_by_top_mngr == false and self.certification_path_status_id == CertificationPathStatus::APPROVING_BY_MANAGEMENT
        CertificationPathTask.create(task_description_id: 25,
                                     application_role: User.role[:gord_manager],
                                     project: self.project,
                                     certification_path: self)
        CertificationPathTask.where(task_description_id: 26, certification_path: self).each do |task|
          task.destroy
        end
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
          CertificationPathTask.where(task_description_id: 26, certification_path: self).each do |task|
            task.destroy
          end
        end
      elsif self.signed_by_mngr == true and self.certification_path_status_id == CertificationPathStatus::APPROVING_BY_MANAGEMENT
        CertificationPathTask.create(task_description_id: 26,
                                     application_role: User.roles[:gord_top_manager],
                                     project: self.project,
                                     certification_path: self)
        CertificationPathTask.where(task_description_id: 27, certification_path: self).each do |task|
          task.destroy
        end
      end
    end
  end

end