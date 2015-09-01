class CertificationPathsController < AuthenticatedController
  before_action :set_project
  before_action :set_certification_path, only: [:show, :sign_certificate]
  load_and_authorize_resource

  def show
    @page_title = "#{@certification_path.certificate.name} for #{@project.name}"
  end

  def create
    @certification_path = CertificationPath.new(certification_path_params)
    @certification_path.status = :registered
    @certification_path.project = @project
    if @certification_path.save
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
      # Do some authorization/validation checks
      if @certification_path.status != certification_path_params[:status]
        case CertificationPath.statuses[certification_path_params[:status]]
          # Only system admins can set status to in_submission
          when CertificationPath.statuses[:in_submission]
            unless current_user.system_admin?
              raise CanCan::AccessDenied.new('Not Authorized to update certification_path status', :update, CertificationPath)
            end
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
        end

        generate_tasks = false

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
          when CertificationPath.statuses[:certified]
            CertificationPathTask.where(flow_index: 16, role: User.roles[:gord_top_manager], project: @project, certification_path: @certification_path).each do |task|
              task.flow_index = 17
              task.role = nil
              task.project_role = ProjectAuthorization.roles[:project_manager]
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

  def sign_certificate
    if params.has_key?(:signed_by_mngr)
      @certification_path.signed_by_mngr = params[:signed_by_mngr]
      @certification_path.save!

      CertificationPathTask.where(flow_index: 14, role: User.roles[:gord_manager], project: @project, certification_path: @certification_path).each do |task|
        task.flow_index = 15
        task.role = User.roles[:gord_top_manager]
        task.save!
      end

      render json: {msg: "Certificate signed by GORD manager"} and return
    end
    if params.has_key?(:signed_by_top_mngr)
      @certification_path.signed_by_top_mngr = params[:signed_by_top_mngr]
      @certification_path.save!

      CertificationPathTask.where(flow_index: 15, role: User.roles[:gord_top_manager], project: @project, certification_path: @certification_path).each do |task|
        task.flow_index = 16
        task.save!
      end

      render json: {msg: "Certificate signed by GORD top manager"} and return
    end
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
end
