class DashboardController < AuthenticatedController
  load_and_authorize_resource class: false
  before_action :set_user
  
  def index
    @page_title = t('dashboard.index.title')

    #Credentials Overdue Tasks or Credentials Overdue Tasks
    @overdue_licences = AccessLicence.user_overdue_access_licences(@user.id)

    # Affiliated Practitioner Accreditation
    @service_provider_user_licences_design = AccessLicence.users_of_service_provider(@user, Certificate.certificate_types[:design_type])
    @service_provider_user_licences_construction = AccessLicence.users_of_service_provider(@user, Certificate.certificate_types[:construction_type])
    @service_provider_user_licences_operation = AccessLicence.users_of_service_provider(@user, Certificate.certificate_types[:operations_type])

    # Practitioner Accreditation Or Corporate License
    @user_licences_design = @user.access_licences.with_certificate_type(Certificate.certificate_types[:design_type])
    @user_licences_construction = @user.access_licences.with_certificate_type(Certificate.certificate_types[:construction_type])
    @user_licences_operation = @user.access_licences.with_certificate_type(Certificate.certificate_types[:operations_type])

    # Projects status
    @total_cgp_for_completed_projects = Project.total_completed_project_by_role(@user, ProjectsUser.roles[:cgp_project_manager], CertificationPathStatus::CERTIFIED) 
    @total_team_member_for_completed_projects = Project.total_completed_project_by_role(@user, ProjectsUser.roles[:project_team_member], CertificationPathStatus::CERTIFIED)
    @total_cgp_for_inprogress_projects = Project.total_inprogress_project_by_role(@user, ProjectsUser.roles[:cgp_project_manager], CertificationPathStatus::CERTIFIED).count 
    @total_team_member_for_inprogress_projects = Project.total_inprogress_project_by_role(@user, ProjectsUser.roles[:project_team_member], CertificationPathStatus::CERTIFIED).count 
  end

  def upload_document
    
    if @user.user_detail.present?
      case user_params[:file_name]
        when "education_certificate"
          @user.user_detail.education_certificate = user_params[:file]
        when "work_experience_file"
          @user.user_detail.work_experience_file = user_params[:file]
        when "other_documents"
          @user.user_detail.other_documents = user_params[:file]
        when "qid_work_permit_file"
          @user.user_detail.qid_work_permit_file = user_params[:file]
        when "application_form"
          @user.service_provider_detail.application_form = user_params[:file]
      end
      @user.save(validate: false)
    end
  
    redirect_to dashboard_path, notice: "Document updated successfully" and return
  end

  private

  def set_user
    @user = current_user
  end

  def user_params
    if User.is_service_provider(current_user)
      user_params = params.require(:service_provider).permit(
        :file,
        :file_name
      )
    else
      user_params = params.require(:user).permit(
        :file,
        :file_name
      )
    end
  end

end
