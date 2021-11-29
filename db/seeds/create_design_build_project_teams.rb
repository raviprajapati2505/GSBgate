ProjectsUser.update_all(certification_team_type: "Other")

# For CDA
projects_with_cda = Project.joins(certification_paths: :certificate).where("projects.certificate_type = :type AND certificates.certification_type = :name", type: 3, name: Certificate.certification_types["final_design_certificate"])

projects_with_cda.each do |project|
  projects_users = project.projects_users.where(certification_team_type: "Other")
  projects_users.each do |project_user|
    new_project_user = project_user.dup
    new_project_user.certification_team_type = "Final Design Certificate"
    new_project_user.save!
  end
end

# For LOC
projects_with_loc = Project.joins(certification_paths: :certificate).where("projects.certificate_type = :type AND certificates.certification_type = :name", type: 3, name: Certificate.certification_types["letter_of_conformance"])
ProjectsUser.joins(:project).where(projects: {id: projects_with_loc.ids}, certification_team_type: "Other").update_all(certification_team_type: "Letter of Conformance")

# Projects with only LOC certified
projects_with_only_loc_certified = Project.joins(certification_paths: [:certification_path_status, :certificate]).where("projects.certificate_type = :type AND certificates.certification_type = :name AND certification_path_statuses.name = :status_name", type: 3, name: Certificate.certification_types["letter_of_conformance"], status_name: "Certified")
projects_with_only_loc_certified.each do |project|
  project_cgp_user = project.projects_users&.find_by(role: "cgp_project_manager")
  if project_cgp_user.present?
    new_project_cgp_user = project_cgp_user.dup
    new_project_cgp_user.certification_team_type = "Final Design Certificate"
    new_project_cgp_user.save
  end
end
