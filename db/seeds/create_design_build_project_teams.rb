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
