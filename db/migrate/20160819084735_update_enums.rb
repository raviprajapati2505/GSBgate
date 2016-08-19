class UpdateEnums < ActiveRecord::Migration
  def change
  #   update certificate certificate_type
    Certificate.where(certificate_type: 0).update_all(certificate_type: Certificate.certificate_types[:design_type])
  #   update certificate assessment stage
    Certificate.where(assessment_stage: 0).update_all(assessment_stage: Certificate.assessment_stages[:design_stage])
  #   update projects user role
    ProjectsUser.where(role: 0).update_all(role: ProjectsUser.roles[:project_team_member])
  #   update requirement datum status
    RequirementDatum.where(status: 0).update_all(status: RequirementDatum.statuses[:required])
  #   update scheme mix criteria document status
    SchemeMixCriteriaDocument.where(status: 0).update_all(status: SchemeMixCriteriaDocument.statuses[:awaiting_approval])
  #   update user role
    User.where(role: 0).update_all(role: User.roles[:system_admin])
  end
end
