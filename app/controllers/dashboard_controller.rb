class DashboardController < AuthenticatedController

  def index
    @page_title = t('dashboard.index.title_service_provider')

    #Credentials Overdue Tasks or Credentials Overdue Tasks
    @overdue_licences = AccessLicence.user_overdue_access_licences(current_user.id)

    # Affiliated Practitioner Accreditation
    @service_provider_user_licences_design = AccessLicence.users_of_service_provider(current_user, Certificate.certificate_types[:design_type])
    @service_provider_user_licences_construction = AccessLicence.users_of_service_provider(current_user, Certificate.certificate_types[:construction_type])
    @service_provider_user_licences_operation = AccessLicence.users_of_service_provider(current_user, Certificate.certificate_types[:operations_type])

    # Practitioner Accreditation Or Corporate License
    @user_licences_design = current_user.access_licences.with_certificate_type(Certificate.certificate_types[:design_type])
    @user_licences_construction = current_user.access_licences.with_certificate_type(Certificate.certificate_types[:construction_type])
    @user_licences_operation = current_user.access_licences.with_certificate_type(Certificate.certificate_types[:operations_type])

    # Projects status
    @total_cgp_for_completed_projects = Project.total_completed_project_by_role(current_user, ProjectsUser.roles[:cgp_project_manager], CertificationPathStatus::CERTIFIED) 
    @total_team_member_for_completed_projects = Project.total_completed_project_by_role(current_user, ProjectsUser.roles[:project_team_member], CertificationPathStatus::CERTIFIED)
    @total_cgp_for_inprogress_projects = Project.total_inprogress_project_by_role(current_user, ProjectsUser.roles[:cgp_project_manager], CertificationPathStatus::CERTIFIED).count 
    @total_team_member_for_inprogress_projects = Project.total_inprogress_project_by_role(current_user, ProjectsUser.roles[:project_team_member], CertificationPathStatus::CERTIFIED).count 
  end

end
