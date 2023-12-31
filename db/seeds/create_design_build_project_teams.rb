ProjectsUser.update_all(certification_team_type: "Other")

# For CDA
projects_with_cda = Project.joins(certification_paths: :certificate).where("projects.certificate_type = :type AND certificates.certification_type = :name", type: 3, name: Certificate.certification_types["final_design_certificate"])

projects_with_cda.each do |project|
  projects_users = project.projects_users.where.not(role: "enterprise_client").where(certification_team_type: "Other")
  projects_users.each do |project_user|
    new_project_user = project_user.dup
    new_project_user.certification_team_type = "Final Design Certificate"
    new_project_user.save
  end
end

# For LOC
projects_with_loc = Project.joins(certification_paths: :certificate).where("projects.certificate_type = :type AND certificates.certification_type = :name", type: 3, name: Certificate.certification_types["letter_of_conformance"])
ProjectsUser.joins(:project).where.not(role: "enterprise_client").where(projects: {id: projects_with_loc.ids}, certification_team_type: "Other").update_all(certification_team_type: "Letter of Conformance")

# Projects with only LOC certified
projects_with_loc_certified = Project.joins(certification_paths: [:certification_path_status, :certificate]).where("projects.certificate_type = :type AND certificates.certification_type = :name AND certification_path_statuses.name = :status_name", type: 3, name: Certificate.certification_types["letter_of_conformance"], status_name: "Certified").ids.uniq
projects_with_cda = Project.joins(certification_paths: :certificate).where("projects.certificate_type = :type AND certificates.certification_type = :name", type: 3, name: Certificate.certification_types["final_design_certificate"]).ids.uniq

projects_with_only_loc_certified_ids = projects_with_loc_certified - projects_with_cda
projects_with_only_loc_certified = Project.find(projects_with_only_loc_certified_ids)
projects_with_only_loc_certified.each do |project|
  project_managers = project.projects_users&.where(role: ["cgp_project_manager", "certification_manager"])
  project_managers.each do |project_manager|
    new_project_manager = project_manager.dup
    new_project_manager.certification_team_type = "Final Design Certificate"
    new_project_manager.save
  end
end

# Those project users whose project is not choosen certification
all_projects_ids = Project.ids.uniq
cert_projects_ids = Project.joins(:certification_paths).ids.uniq
new_projects_ids = all_projects_ids - cert_projects_ids

new_projects_ids.each do |project_id|
  project = Project.find(project_id)
  if project.present?
    if project.certificate_type == 3
      project&.projects_users&.where.not(role: "enterprise_client").update_all(certification_team_type: "Letter of Conformance")
    else
      project&.projects_users&.update_all(certification_team_type: "Other")
    end
  end
end