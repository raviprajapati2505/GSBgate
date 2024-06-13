class DashboardController < AuthenticatedController
  load_and_authorize_resource class: false, except: [:confirm_destroy_demerit]
  before_action :set_user
  
  def index
    @page_title = t('dashboard.index.title')

    #Credentials Overdue Tasks or Credentials Overdue Tasks
    @overdue_licences = AccessLicence.user_overdue_access_licences(@user.id)

    # Affiliated Practitioner Accreditation
    @service_provider_user_licences_energy_centers_efficiency = AccessLicence.users_of_service_provider(@user, Certificate.certificate_types[:energy_centers_efficiency_type])
    @service_provider_user_licences_building_energy_efficiency = AccessLicence.users_of_service_provider(@user, Certificate.certificate_types[:building_energy_efficiency_type])
    @service_provider_user_licences_healthy_buildings = AccessLicence.users_of_service_provider(@user, Certificate.certificate_types[:healthy_buildings_type])
    @service_provider_user_licences_indoor_air_quality = AccessLicence.users_of_service_provider(@user, Certificate.certificate_types[:indoor_air_quality_type])
    @service_provider_user_licences_measurement_reporting_and_verification = AccessLicence.users_of_service_provider(@user, Certificate.certificate_types[:measurement_reporting_and_verification_type])
    @service_provider_user_licences_building_water_efficiency = AccessLicence.users_of_service_provider(@user, Certificate.certificate_types[:building_water_efficiency_type])
    @service_provider_user_licences_events_carbon_neutrality = AccessLicence.users_of_service_provider(@user, Certificate.certificate_types[:events_carbon_neutrality_type])
    @service_provider_user_licences_products_ecolabeling = AccessLicence.users_of_service_provider(@user, Certificate.certificate_types[:products_ecolabeling_type])
    @service_provider_user_licences_green_IT = AccessLicence.users_of_service_provider(@user, Certificate.certificate_types[:green_IT_type])
    @service_provider_user_licences_net_zero = AccessLicence.users_of_service_provider(@user, Certificate.certificate_types[:net_zero_type])
    @service_provider_user_licences_energy_label_waste_water_treatment_facility = AccessLicence.users_of_service_provider(@user, Certificate.certificate_types[:energy_label_waste_water_treatment_facility_type])


    # Practitioner Accreditation Or Corporate License
    @user_licences_energy_centers_efficiency = @user.access_licences.with_certificate_type(Certificate.certificate_types[:energy_centers_efficiency_type])
    @user_licences_building_energy_efficiency = @user.access_licences.with_certificate_type(Certificate.certificate_types[:building_energy_efficiency_type])
    @user_licences_healthy_buildings = @user.access_licences.with_certificate_type(Certificate.certificate_types[:healthy_buildings_type])
    @user_licences_indoor_air_quality = @user.access_licences.with_certificate_type(Certificate.certificate_types[:indoor_air_quality_type])
    @user_licences_measurement_reporting_and_verification = @user.access_licences.with_certificate_type(Certificate.certificate_types[:measurement_reporting_and_verification_type])
    @user_licences_building_water_efficiency = @user.access_licences.with_certificate_type(Certificate.certificate_types[:building_water_efficiency_type])
    @user_licences_events_carbon_neutrality = @user.access_licences.with_certificate_type(Certificate.certificate_types[:events_carbon_neutrality_type])
    @user_licences_products_ecolabeling = @user.access_licences.with_certificate_type(Certificate.certificate_types[:products_ecolabeling_type])
    @user_licences_green_IT = @user.access_licences.with_certificate_type(Certificate.certificate_types[:green_IT_type])
    @user_licences_net_zero = @user.access_licences.with_certificate_type(Certificate.certificate_types[:net_zero_type])
    @user_licences_energy_label_waste_water_treatment_facility = @user.access_licences.with_certificate_type(Certificate.certificate_types[:energy_label_waste_water_treatment_facility_type])


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
        when "gsb_trust_notification"
          demerit_flag.gsb_trust_notification = user_params[:file]
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
      if User.is_service_provider(@user)
        if @user.service_provider_detail.present?
          case user_params[:file_name]
            when "application_form"
              @user.service_provider_detail.application_form = user_params[:file]
            when "portfolio"
                @user.service_provider_detail.portfolio = user_params[:file]
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
    if params[:service_provider].present?
      user_params = params.require(:service_provider).permit(
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
