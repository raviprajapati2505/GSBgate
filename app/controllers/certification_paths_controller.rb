class CertificationPathsController < AuthenticatedController
  before_action :set_project
  before_action :set_certification_path, only: [:show]
  load_and_authorize_resource

  def show
    @page_title = "#{@certification_path.certificate.label} for #{@project.name}"
  end

  def create
    @certification_path = CertificationPath.new(certification_path_params)
    @certification_path.status = :registered
    @certification_path.project = @project
    if @certification_path.save
        # Generate a notification for the system admins
        User.system_admin.each do |system_admin|
          notify(body: 'A new application for a %s was created.',
                 body_params: [@certification_path.certificate.label],
                 uri: project_path(@project),
                 user: system_admin,
                 project: @project)
        end

        # Generate a task for the system admins
        if @project.certifier_manager_assigned?
          CertificationPathTask.create!(flow_index: 2, role: User.roles[:system_admin], project: @project, certification_path: @certification_path)
        else
          CertificationPathTask.create!(flow_index: 1, role: User.roles[:system_admin], project: @project, certification_path: @certification_path)
        end

        redirect_to project_path(@project), notice: 'Successfully applied for certificate.'
    else
      redirect_to project_path(@project), notice: 'Error, could not apply for certificate'
      # todo handle @certification_path.errors.
    end
  end

  def update
    CertificationPath.transaction do
      generate_tasks = false
      if @certification_path.status != certification_path_params[:status]
        generate_notifications(certification_path_params[:status])

        case CertificationPath.statuses[certification_path_params[:status]]
          # Generate tasks for project managers
          when CertificationPath.statuses[:in_submission]
            # Delete system admin task
            CertificationPathTask.where(flow_index: 2, role: User.roles[:system_admin], project: @project, certification_path: @certification_path).each do |task|
              task.destroy
            end
            generate_tasks = true
          when CertificationPath.statuses[:in_screening]
            # Delete project manager task
            CertificationPathTask.where(flow_index: 6, project_role: ProjectAuthorization.roles[:project_manager], project: @project, certification_path: @certification_path).each do |task|
              task.destroy
            end
            # Generate tasks for certifier managers
            @certification_path.scheme_mixes.each do |scheme_mix|
              scheme_mix.scheme_mix_criteria.each do |scheme_mix_criterion|
                SchemeMixCriterionTask.create!(flow_index: 7, project_role: ProjectAuthorization.roles[:certifier_manager], project: @project, scheme_mix_criterion: scheme_mix_criterion)
              end
            end
          when CertificationPath.statuses[:screened]
            CertificationPathTask.where(flow_index: 9, project_role: ProjectAuthorization.roles[:certifier_manager], project: @project, certification_path: @certification_path).each do |task|
              task.flow_index = 10
              task.project_role = ProjectAuthorization.roles[:project_manager]
              task.save!
            end
          when CertificationPath.statuses[:in_verification]
            # Delete project manager task
            CertificationPathTask.where(flow_index: 10, project_role: ProjectAuthorization.roles[:project_manager], project: @project, certification_path: @certification_path).each do |task|
              task.destroy
            end
            # Generate tasks for certifier members
            @certification_path.scheme_mixes.each do |scheme_mix|
              scheme_mix.scheme_mix_criteria.each do |scheme_mix_criterion|
                SchemeMixCriterionTask.create!(flow_index: 11, user: scheme_mix_criterion.certifier, project: @project, scheme_mix_criterion: scheme_mix_criterion)
              end
            end
          when CertificationPath.statuses[:awaiting_approval]
            CertificationPathTask.where(flow_index: 12, project_role: ProjectAuthorization.roles[:certifier_manager], project: @project, certification_path: @certification_path).each do |task|
              task.flow_index = 13
              task.project_role = ProjectAuthorization.roles[:project_manager]
              task.save!
            end
          when CertificationPath.statuses[:awaiting_signatures]
            CertificationPathTask.where(flow_index: 13, project_role: ProjectAuthorization.roles[:project_manager], project: @project, certification_path: @certification_path).each do |task|
              task.flow_index = 14
              task.project_role = nil
              task.role = User.roles[:gord_manager]
              task.save!
            end
        end
      end

      if @certification_path.update(certification_path_params)
        if @certification_path.scheme_mixes.empty?
          @certification_path.create_descendant_records

          if generate_tasks
            # Generate tasks for project managers
            @certification_path.scheme_mixes.each do |scheme_mix|
              scheme_mix.scheme_mix_criteria.each do |scheme_mix_criterion|
                scheme_mix_criterion.requirement_data.each do |requirement_data|
                  RequirementDatumTask.create!(flow_index: 3, project_role: ProjectAuthorization.roles[:project_manager], project: @project, scheme_mix_criterion: scheme_mix_criterion, requirement_datum: requirement_data)
                end
              end
            end
          end
        end
        redirect_to project_certification_path_path(@project, @certification_path), notice: 'Status was successfully updated.'
      else
        render action: :show
      end
    end
  end

  def download_archive
    send_file DocumentArchiverService.instance.create_archive(@certification_path.scheme_mix_criteria_documents.approved)
  end

  private
    def set_project
      @project = Project.find(params[:project_id])
    end

    def set_certification_path
      @certification_path = CertificationPath.find(params[:id])
    end

    def certification_path_params
      params.require(:certification_path).permit(:certificate_id, :status)
    end

    def generate_state_change_notification(new_status, user)
      notify(body: 'The status of %s was changed to %s.',
             body_params: [@certification_path.certificate.label, new_status.humanize],
             uri: project_certification_path_path(@project, @certification_path),
             user: user,
             project: @project)
    end

    def generate_notifications(new_status)
      case CertificationPath.statuses[new_status]
        # Only system admins can set status to in_submission
        when CertificationPath.statuses[:in_submission]
          unless current_user.system_admin?
            raise CanCan::AccessDenied.new('Not Authorized to update certification_path status', :update, CertificationPath)
          end
          # Generate a notification for the project owner
          generate_state_change_notification(new_status, @project.owner)
        # Only project managers can set status to in_screening
        when CertificationPath.statuses[:in_screening]
          # all scheme mix criteria must be marked as 'complete'
          @certification_path.scheme_mix_criteria.each do |scheme_mix_criteria|
            unless scheme_mix_criteria.complete?
              flash.now[:alert] = 'All scheme mix criteria should first be completed.'
              render :show
              return
            end
          end

          # Generate a notification for the certifier managers
          ProjectAuthorization.for_project(@project).certifier_manager.each do |project_authorization|
            generate_state_change_notification(new_status, project_authorization.user)
          end
        # Only certifier managers can set status to screened
        when CertificationPath.statuses[:screened]
          # Generate a notification for the project managers
          ProjectAuthorization.for_project(@project).project_manager.each do |project_authorization|
            generate_state_change_notification(new_status, project_authorization.user)
          end
        # Only project managers can set status to awaiting_pcr_admittance
        when CertificationPath.statuses[:awaiting_pcr_admittance]
          # Generate a notification for the system admins
          User.system_admin.each do |system_admin|
            generate_state_change_notification(new_status, system_admin)
          end
        # Only system admins can set status to in_review
        when CertificationPath.statuses[:in_review]
          # Generate a notification for the certifiers
          ProjectAuthorization.for_project(@project).certifier.each do |project_authorization|
            generate_state_change_notification(new_status, project_authorization.user)
          end
        # Only certifier managers can set status to reviewed
        when CertificationPath.statuses[:reviewed]
          # Generate a notification for project managers
          ProjectAuthorization.for_project(@project).project_manager.each do |project_authorization|
            generate_state_change_notification(new_status, project_authorization.user)
          end
        # Only project managers can set status to in_verification
        when CertificationPath.statuses[:in_verification]
          # Generate a notification for certifiers
          ProjectAuthorization.for_project(@project).certifier.each do |project_authorization|
            generate_state_change_notification(new_status, project_authorization.user)
          end
        # Only certifier managers can set status to certification_rejected
        when CertificationPath.statuses[:certification_rejected]
          # Generate a notification for project managers
          ProjectAuthorization.for_project(@project).project_manager.each do |project_authorization|
            generate_state_change_notification(new_status, project_authorization.user)
          end
        # Only certifier managers can set status to awaiting_approval
        when CertificationPath.statuses[:awaiting_approval]
          # Generate a notification for project managers
          ProjectAuthorization.for_project(@project).project_manager.each do |project_authorization|
            generate_state_change_notification(new_status, project_authorization.user)
          end
        # Only project managers can set status to awaiting_signatures
        when CertificationPath.statuses[:awaiting_signatures]
          # Generate a notification for GORD manager
          User.gord_manager.each do |gord_manager|
            generate_state_change_notification(new_status, gord_manager)
          end
        # Only gord_top_managers can set status to certified
        when CertificationPath.statuses[:certified]
          # Generate a notification for project managers
          ProjectAuthorization.for_project(@project).project_manager.each do |project_authorization|
            generate_state_change_notification(new_status, project_authorization.user)
          end
      end
    end
end
