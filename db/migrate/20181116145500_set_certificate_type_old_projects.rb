class SetCertificateTypeOldProjects < ActiveRecord::Migration
  def change
    # Get all Design & Build projects
    projects = Project.joins(certification_paths: [:certificate]).where(certificates: {certificate_type: Certificate.certificate_types[:design_type]}).distinct
    projects.each do |project|
      project.update_column(:certificate_type, Certificate.certificate_types[:design_type])
    end

    # Get all Construction Management projects
    projects = Project.joins(certification_paths: [:certificate]).where(certificates: {certificate_type: Certificate.certificate_types[:construction_type]}).distinct
    projects.each do |project|
      project.update_column(:certificate_type, Certificate.certificate_types[:construction_type])
    end

    # Get all Operation projects
    projects = Project.joins(certification_paths: [:certificate]).where(certificates: {certificate_type: Certificate.certificate_types[:operations_type]}).distinct
    projects.each do |project|
      project.update_column(:certificate_type, Certificate.certificate_types[:operations_type])
    end
  end
end
