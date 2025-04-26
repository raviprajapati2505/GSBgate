class DashboardController < AuthenticatedController
  load_and_authorize_resource class: false, except: [:confirm_destroy_demerit]
  before_action :set_user
  
  def index
    @page_title = t('dashboard.index.title')

    #Credentials Overdue Tasks or Credentials Overdue Tasks
    @overdue_licences = AccessLicence.user_overdue_access_licences(@user.id)
    # Affiliated Practitioner Accreditation
    Certificate::CERTIFICATE_TYPES.each do |cert_type|
      instance_variable_set("@corporate_user_licences_#{cert_type}",
      AccessLicence.users_of_corporate(@user, Certificate.certificate_types[:"#{cert_type}_type"]))  
    end  

    # Practitioner Accreditation Or Corporate License
    Certificate::CERTIFICATE_TYPES.each do |cert_type|
      instance_variable_set("@user_licences_#{cert_type}",
      @user.access_licences.with_certificate_type(Certificate.certificate_types[:"#{cert_type}_type"]))
    end

    # Projects status
    @total_cgp_for_completed_projects = Project.total_completed_project_by_role(@user, ProjectsUser.roles[:cgp_project_manager], CertificationPathStatus::CERTIFIED)
    @total_team_member_for_completed_projects = Project.total_completed_project_by_role(@user, ProjectsUser.roles[:project_team_member], CertificationPathStatus::CERTIFIED)
    @total_cgp_for_inprogress_projects = Project.total_inprogress_project_by_role(@user, ProjectsUser.roles[:cgp_project_manager], CertificationPathStatus::CERTIFIED).count
    @total_team_member_for_inprogress_projects = Project.total_inprogress_project_by_role(@user, ProjectsUser.roles[:project_team_member], CertificationPathStatus::CERTIFIED).count
  end

  def upload_document
    if user_params[:demerit_flag].present?
      demerit_flag = DemeritFlag.find(user_params[:demerit_flag])
      case user_params[:file_name]
        when "gsb_notification"
          demerit_flag.gsb_notification = user_params[:file]
        when "practitioner_acknowledge"
          demerit_flag.practitioner_acknowledge = user_params[:file]
      end
      demerit_flag.save
      redirect_to dashboard_user_path(demerit_flag.user.id), notice: "Demerit Document updated successfully" and return
    elsif user_params[:access_licence_id].present?
      access_licence = AccessLicence.find(user_params[:access_licence_id])
      access_licence.licence_file = user_params[:file]
      access_licence.save
      redirect_to dashboard_user_path(access_licence.user.id), notice: "Licence Document updated successfully" and return
    else
      if User.is_corporate(@user)
        if @user.corporate_detail.present?
          case user_params[:file_name]
            when "application_form"
              @user.corporate_detail.application_form = user_params[:file]
            when "portfolio"
                @user.corporate_detail.portfolio = user_params[:file]
            end
          @user.save(validate: false)
          redirect_to dashboard_path, notice: "Document updated successfully" and return
        else
          redirect_to dashboard_path, alert: "Please fill full profile details first" and return
        end
      else
        if @user.user_detail.present?
          case user_params[:file_name]
            when "university_credentials_file"
              @user.user_detail.university_credentials_file = user_params[:file]
            when "work_experience_file"
              @user.user_detail.work_experience_file = user_params[:file]
            when "other_documents"
              @user.user_detail.other_documents = user_params[:file]
            when "qid_work_permit_file"
              @user.user_detail.qid_work_permit_file = user_params[:file]
          end
          @user.save(validate: false)
          redirect_to dashboard_path, notice: "Document updated successfully" and return
        else
          redirect_to dashboard_path, alert: "Please fill full profile details first" and return
        end
      end
    end
  end

  def confirm_destroy_demerit
    DemeritFlag.find(params[:demerit_id]).destroy
    redirect_to dashboard_user_path(@user.id), notice: "Demerit flag removed successfully" and return
  end

  private

  def set_user
    if params[:user_id]
      @user = User.find(params[:user_id])
    else
      @user = current_user
    end
  end

  def user_params
    if params[:corporate].present?
      user_params = params.require(:corporate).permit(
        :file,
        :file_name,
        :demerit_flag,
        :access_licence_id
      )
    else
      user_params = params.require(:user).permit(
        :file,
        :file_name,
        :demerit_flag,
        :access_licence_id
      )
    end
  end

end
