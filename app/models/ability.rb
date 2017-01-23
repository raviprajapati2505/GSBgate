class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here.
    #
    # The first argument to `can` is the action you are giving the user permission to do.
    #   :manage it will apply to every action.
    #   :crud is an alias for the common actions: [:read, :create, :update and :destroy]
    #
    # The second argument is the resource the user can perform the action on.
    #   :all it will apply to every resource.
    #   Otherwise pass a Ruby class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the objects.
    # In case of complex conditions, you can also pass a block
    #
    # See the wiki for details:
    # https://github.com/ryanb/cancan/wiki/Defining-Abilities

    user ||= User.new # guest user (not logged in)

    alias_action :create, :read, :update, :destroy, :to => :crud

    # Some convenience variables to work with enums in conditions
    #   Note: there is a known issue, that complicates working with enums
    #     https://github.com/CanCanCommunity/cancancan/pull/196
    #   ProjectsUser Roles
    project_user_role_cgp_project_manager = ['cgp_project_manager', ProjectsUser.roles[:cgp_project_manager]]
    project_user_role_project_team_member = ['project_team_member', ProjectsUser.roles[:project_team_member]]
    project_user_role_certification_manager = ['certification_manager', ProjectsUser.roles[:certification_manager]]
    project_user_role_certifier = ['certifier', ProjectsUser.roles[:certifier]]
    project_user_role_enterprise_client = ['enterprise_client', ProjectsUser.roles[:enterprise_client]]
    project_user_project_team_roles = project_user_role_cgp_project_manager | project_user_role_project_team_member
    project_user_gsas_trust_team_roles = project_user_role_certification_manager | project_user_role_certifier
    project_user_enterprise_client_roles = project_user_role_enterprise_client
    #   Certificate.certification_types
    certificate_certification_types_letter_of_conformance = ['letter_of_conformance', Certificate.certification_types[:letter_of_conformance]]
    certificate_certification_types_final_design_certificate = ['final_design_certificate', Certificate.certification_types[:final_design_certificate]]
    certificate_certification_types_construction_certificate = ['construction_certificate', Certificate.certification_types[:construction_certificate]]
    certificate_certification_types_operations_certificate = ['operations_certificate', Certificate.certification_types[:operations_certificate]]
    #   SchemeMixCriterion.statuses
    scheme_mix_criterion_status_submitting = ['submitting', SchemeMixCriterion.statuses[:submitting], 'submitting_after_appeal', SchemeMixCriterion.statuses[:submitting_after_appeal]]
    scheme_mix_criterion_status_submitted = ['submitted', SchemeMixCriterion.statuses[:submitted], 'submitted_after_appeal', SchemeMixCriterion.statuses[:submitted_after_appeal]]
    scheme_mix_criterion_status_verifying = ['verifying', SchemeMixCriterion.statuses[:verifying], 'verifying_after_appeal', SchemeMixCriterion.statuses[:verifying_after_appeal]]
    scheme_mix_criterion_status_verified = ['score_awarded', SchemeMixCriterion.statuses[:score_awarded], 'score_downgraded', SchemeMixCriterion.statuses[:score_downgraded], 'score_upgraded', SchemeMixCriterion.statuses[:score_upgraded], 'score_minimal', SchemeMixCriterion.statuses[:score_minimal], 'score_awarded_after_appeal', SchemeMixCriterion.statuses[:score_awarded_after_appeal], 'score_downgraded_after_appeal', SchemeMixCriterion.statuses[:score_downgraded_after_appeal], 'score_upgraded_after_appeal', SchemeMixCriterion.statuses[:score_upgraded_after_appeal], 'score_minimal_after_appeal', SchemeMixCriterion.statuses[:score_minimal_after_appeal]]
    #   SchemeMixCriteriaDocument.statuses
    document_approved = ['approved', SchemeMixCriteriaDocument.statuses[:approved]]

    # Convenience conditions, to use within abilities
    project_with_user_assigned = {projects_users: {user_id: user.id}}
    project_with_user_as_cgp_project_manager = {projects_users: {user_id: user.id, role: project_user_role_cgp_project_manager}}
    project_with_user_in_project_team = {projects_users: {user_id: user.id, role: project_user_project_team_roles}}
    project_with_user_as_certification_manager = {projects_users: {user_id: user.id, role: project_user_role_certification_manager}}
    project_with_user_in_gsas_trust_team = {projects_users: {user_id: user.id, role: project_user_gsas_trust_team_roles}}
    project_with_user_as_enterprise_client = {projects_users: {user_id: user.id, role: project_user_enterprise_client_roles}}

    # ------------------------------------------------------------------------------------------------------------
    # There are 3 types of user roles:
    #   - USERS, can see ONLY projects they are linked with
    #     - default_role
    #   - ADMIN, can see ALL projects, without explicitly being linked to it
    #     - gsas_trust_admin
    #     - gsas_trust_manager
    #     - gsas_trust_top_manager
    #   - SYSTEM, can do anything, only needed for testing or emergencies!
    #     - system_admin
    # ------------------------------------------------------------------------------------------------------------
    if user.default_role?
      # Project controller
      can :read, Project, projects_users: {user_id: user.id}
      can [:download_location_plan, :download_site_plan, :download_design_brief, :download_project_narrative], Project, projects_users: {user_id: user.id}
      can :show_tools, Project, projects_users: {user_id: user.id}
      cannot :update, Project, projects_users: {user_id: user.id, role: project_user_role_cgp_project_manager}, certification_paths: {certification_path_status: {id: CertificationPathStatus::STATUSES_ACTIVATED}}
      can :update, Project, projects_users: {user_id: user.id, role: project_user_role_cgp_project_manager}
      if user.cgp_license?
        can :create, Project
      end

      # ProjectsUsers controller - Project team
      can :read, ProjectsUser, role: project_user_project_team_roles, project: project_with_user_assigned
      can [:create, :destroy], ProjectsUser, role: project_user_role_project_team_member, project: project_with_user_as_cgp_project_manager

      # ProjectsUsers controller - GSAS trust team
      can :read, ProjectsUser, role: project_user_gsas_trust_team_roles, project: project_with_user_in_gsas_trust_team
      can [:create, :destroy], ProjectsUser, role: project_user_role_certifier, project: project_with_user_as_certification_manager

      # ProjectsUsers controller - Enterprise clients
      can :read, ProjectsUser, role: project_user_enterprise_client_roles, project: project_with_user_assigned

      # ProjectsUsers controller - You can't add yourself
      cannot :create, ProjectsUser, user_id: user.id

      # CertificationPath controller
      can :read, CertificationPath, project: project_with_user_assigned
      can :list, CertificationPath, project: project_with_user_assigned
      can [:download_certificate_report, :download_coverletter_report, :download_scores_report], CertificationPath, project: project_with_user_assigned
      can :download_archive, CertificationPath, project: project_with_user_assigned
      # Project team
      can :apply, CertificationPath, project: project_with_user_as_cgp_project_manager
      can [:edit_status, :update_status], CertificationPath, certification_path_status: {id: CertificationPathStatus::STATUSES_AT_PROJECT_TEAM_SIDE}, project: project_with_user_as_cgp_project_manager
      can [:edit_project_team_responsibility, :allocate_project_team_responsibility], CertificationPath, project: project_with_user_as_cgp_project_manager, certification_path_status: {id: CertificationPathStatus::STATUSES_IN_SUBMISSION}
      # GSAS trust team
      can [:edit_status, :update_status], CertificationPath, certification_path_status: {id: CertificationPathStatus::STATUSES_AT_CERTIFIER_SIDE}, project: project_with_user_as_certification_manager
      can [:edit_certifier_team_responsibility, :allocate_certifier_team_responsibility], CertificationPath, project: project_with_user_as_certification_manager, certification_path_status: {id: CertificationPathStatus::STATUSES_IN_VERIFICATION}

      # SchemeMix controller
      can :read, SchemeMix, certification_path: {project: project_with_user_assigned, certification_path_status: {id: CertificationPathStatus::STATUSES_ACTIVATED}}
      # TODO ????????????
      #can :update, SchemeMix, certification_path: {project: project_with_user_as_cgp_project_manager, certification_path_status: {id: CertificationPathStatus::ACTIVATING}, development_type: {mixable: true}}
      can :update, SchemeMix, certification_path: {project: project_with_user_as_cgp_project_manager, certification_path_status: {id: CertificationPathStatus::ACTIVATING}}

      # SchemeMixCriterion controller
      can :read, SchemeMixCriterion, scheme_mix: {certification_path: {project: project_with_user_assigned, certification_path_status: {id: CertificationPathStatus::STATUSES_ACTIVATED}}}
      can :list, SchemeMixCriterion, scheme_mix: {certification_path: {project: project_with_user_assigned, certification_path_status: {id: CertificationPathStatus::STATUSES_ACTIVATED}}}
      # Project team
      can [:edit_status, :update_status], SchemeMixCriterion, main_scheme_mix_criterion: nil, status: scheme_mix_criterion_status_submitting, scheme_mix: {certification_path: {certification_path_status: {id: CertificationPathStatus::STATUSES_IN_SUBMISSION}, project: project_with_user_as_cgp_project_manager}}
      # allows a submitted state, to be reset
      can [:edit_status, :update_status], SchemeMixCriterion, main_scheme_mix_criterion: nil, status: scheme_mix_criterion_status_submitted, scheme_mix: {certification_path: {certification_path_status: {id: CertificationPathStatus::STATUSES_IN_SUBMISSION}, project: project_with_user_as_cgp_project_manager}}
      # Managers can update scores depending on the status
      can :update_targeted_score, SchemeMixCriterion, main_scheme_mix_criterion: nil, status: scheme_mix_criterion_status_submitting, scheme_mix: {certification_path: {project: project_with_user_as_cgp_project_manager}}
      can :update_submitted_score, SchemeMixCriterion, main_scheme_mix_criterion: nil, status: scheme_mix_criterion_status_submitting, scheme_mix: {certification_path: {project: project_with_user_as_cgp_project_manager}}
      can :update_submitted_score, SchemeMixCriterion, main_scheme_mix_criterion: nil, status: scheme_mix_criterion_status_submitting, requirement_data: {user_id: user.id}, scheme_mix: {certification_path: {project: project_with_user_in_project_team}}
      can :request_review, SchemeMixCriterion, main_scheme_mix_criterion: nil, status: ['submitting', SchemeMixCriterion.statuses[:submitting]], scheme_mix: {certification_path: {certification_path_status: {id: [CertificationPathStatus::SUBMITTING, CertificationPathStatus::SUBMITTING_AFTER_SCREENING]}, project: project_with_user_as_cgp_project_manager, pcr_track: true}}
      # GSAS trust team
      can [:edit_status, :update_status], SchemeMixCriterion, main_scheme_mix_criterion: nil, status: scheme_mix_criterion_status_verifying, scheme_mix: {certification_path: {certification_path_status: {id: CertificationPathStatus::STATUSES_IN_VERIFICATION}, project: project_with_user_as_certification_manager}}
      can [:edit_status, :update_status], SchemeMixCriterion, main_scheme_mix_criterion: nil, status: scheme_mix_criterion_status_verifying, certifier_id: user.id, scheme_mix: {certification_path: {certification_path_status: {id: CertificationPathStatus::STATUSES_IN_VERIFICATION}, project: project_with_user_in_gsas_trust_team}}
      # allows a submitted state, to be reset
      can [:edit_status, :update_status], SchemeMixCriterion, main_scheme_mix_criterion: nil, status: scheme_mix_criterion_status_verified, scheme_mix: {certification_path: {certification_path_status: {id: CertificationPathStatus::STATUSES_IN_VERIFICATION}, project: project_with_user_as_certification_manager}}
      can [:edit_status, :update_status], SchemeMixCriterion, main_scheme_mix_criterion: nil, status: scheme_mix_criterion_status_verified, certifier_id: user.id, scheme_mix: {certification_path: {certification_path_status: {id: CertificationPathStatus::STATUSES_IN_VERIFICATION}, project: project_with_user_in_gsas_trust_team}}
      # Managers can update scores depending on the status
      can :update_achieved_score, SchemeMixCriterion, main_scheme_mix_criterion: nil, status: scheme_mix_criterion_status_verifying, scheme_mix: {certification_path: {project: project_with_user_as_certification_manager}}
      can :update_achieved_score, SchemeMixCriterion, main_scheme_mix_criterion: nil, status: scheme_mix_criterion_status_verifying, certifier_id: user.id, scheme_mix: {certification_path: {project: project_with_user_in_gsas_trust_team}}
      can :assign_certifier, SchemeMixCriterion, main_scheme_mix_criterion: nil, status: scheme_mix_criterion_status_verifying, scheme_mix: {certification_path: {project: project_with_user_as_certification_manager}}
      can [:provide_review_comment, :add_review_comment], SchemeMixCriterion, main_scheme_mix_criterion: nil, in_review: true, scheme_mix: {certification_path: {project: project_with_user_as_certification_manager}}

      # RequirementDatum controller
      can :read, RequirementDatum, scheme_mix_criteria: {scheme_mix: {certification_path: {project: project_with_user_assigned, certification_path_status: {id: CertificationPathStatus::STATUSES_ACTIVATED}}}}
      # Project team
      can :update, RequirementDatum, scheme_mix_criteria: {status: scheme_mix_criterion_status_submitting, scheme_mix: {certification_path: {project: project_with_user_as_cgp_project_manager}}}
      can :update_status, RequirementDatum, user_id: user.id, scheme_mix_criteria: {status: scheme_mix_criterion_status_submitting, scheme_mix: {certification_path: {project: project_with_user_in_project_team}}}
      can :refuse, RequirementDatum, user_id: user.id, scheme_mix_criteria: {status: scheme_mix_criterion_status_submitting, scheme_mix: {certification_path: {project: project_with_user_in_project_team}}}

      # Document controller
      can :read, Document, scheme_mix_criteria_documents: { scheme_mix_criterion: {scheme_mix: {certification_path: {project: project_with_user_assigned}}}}
      # Project team
      can :create, Document, scheme_mix_criteria_documents: { scheme_mix_criterion: {main_scheme_mix_criterion: nil, status: scheme_mix_criterion_status_submitting, scheme_mix: {certification_path: {project: project_with_user_in_project_team}}}}
      can :destroy, Document, scheme_mix_criteria_documents: { scheme_mix_criterion: {main_scheme_mix_criterion: nil, status: scheme_mix_criterion_status_submitting, scheme_mix: {certification_path: {project: project_with_user_as_cgp_project_manager}}}}

      # CertificationPathDocument controller
      can :read, CertificationPathDocument, certification_path: {project: project_with_user_assigned}
      # Project team
      can [:create, :destroy], CgpCertificationPathDocument, certification_path: {project: project_with_user_as_cgp_project_manager}
      # GSAS trust team
      can [:create, :destroy], CertifierCertificationPathDocument, certification_path: {project: project_with_user_as_certification_manager}

      # SchemeMixCriteriaDocument controller
      # Project team
      can :read, SchemeMixCriteriaDocument, scheme_mix_criterion: {scheme_mix: {certification_path: {project: project_with_user_in_project_team}}}
      can [:update_status, :edit_status], SchemeMixCriteriaDocument, scheme_mix_criterion: {status: scheme_mix_criterion_status_submitting, scheme_mix: {certification_path: {project: project_with_user_as_cgp_project_manager}}}
      can [:create_link, :new_link], SchemeMixCriteriaDocument, scheme_mix_criterion: {status: scheme_mix_criterion_status_submitting, scheme_mix: {certification_path: {project: project_with_user_in_project_team}}}
      can [:unlink, :destroy_link], SchemeMixCriteriaDocument, scheme_mix_criterion: {status: scheme_mix_criterion_status_submitting, scheme_mix: {certification_path: {project: project_with_user_as_cgp_project_manager}}}
      # GSAS trust team
      can :read, SchemeMixCriteriaDocument, status: document_approved, scheme_mix_criterion: {scheme_mix: {certification_path: {project: project_with_user_in_gsas_trust_team}}}
      can :read, SchemeMixCriteriaDocument, scheme_mix_criterion: {in_review: true, scheme_mix: {certification_path: {project: project_with_user_in_gsas_trust_team}}}
      # Enterprise clients
      can :read, SchemeMixCriteriaDocument, status: document_approved, scheme_mix_criterion: {scheme_mix: {certification_path: {project: project_with_user_as_enterprise_client}}}

      # AuditLog controller
      can :index, AuditLog, audit_log_visibility_id: AuditLogVisibility::PUBLIC, project: project_with_user_assigned
      can :index, AuditLog, audit_log_visibility_id: AuditLogVisibility::INTERNAL, project: project_with_user_in_gsas_trust_team
      can :auditable_index, AuditLog, audit_log_visibility_id: AuditLogVisibility::PUBLIC, project: project_with_user_assigned
      can :auditable_index, AuditLog, audit_log_visibility_id: AuditLogVisibility::INTERNAL, project: project_with_user_in_gsas_trust_team
      can :auditable_index_comments, AuditLog, audit_log_visibility_id: AuditLogVisibility::PUBLIC, project: project_with_user_assigned
      can :auditable_index_comments, AuditLog, audit_log_visibility_id: AuditLogVisibility::INTERNAL, project: project_with_user_in_gsas_trust_team
      can :auditable_create, AuditLog #TODO:, project: project_with_user_assigned

      # Tasks controller
      can :read, Task
      can :count, Task

      # Tools controller
      can :manage, :tool

      # User controller
      can [:list_notifications,:update_notifications], User, id: user.id
      can :find_users_by_email, User

      # Owner
      can [:index, :show], Owner

    elsif user.gsas_trust_admin? || user.gsas_trust_manager? || user.gsas_trust_top_manager?
      can :read, :all
      # Project
      can [:download_location_plan, :download_site_plan, :download_design_brief, :download_project_narrative], Project
      can :show_tools, Project
      if user.gsas_trust_admin?
        can :update, Project
      end
      # Project Users
      # can :list_users_sharing_projects, ProjectsUser
      # can :list_projects, ProjectsUser
      if user.gsas_trust_admin?
        can :crud, ProjectsUser, role: project_user_role_project_team_member
        can :crud, ProjectsUser, role: project_user_gsas_trust_team_roles
        can :crud, ProjectsUser, role: project_user_enterprise_client_roles
        # You can't add yourself
        cannot :create, ProjectsUser, user_id: user.id
      end
      # Certification Path
      can :list, CertificationPath
      can :apply_for_pcr, CertificationPath, pcr_track: false
      can [:download_certificate_report, :download_coverletter_report, :download_scores_report], CertificationPath
      can :download_archive, CertificationPath
      if user.gsas_trust_admin?
        can [:edit_main_scheme_mix, :update_main_scheme_mix], CertificationPath, certification_path_status: {id: CertificationPathStatus::ACTIVATING}, development_type: {mixable: true}
        can [:edit_status, :update_status], CertificationPath, certification_path_status: {id: CertificationPathStatus::STATUSES_AT_ADMIN_SIDE}
        can [:edit_status, :update_status], CertificationPath, certification_path_status: {id: CertificationPathStatus::STATUSES_AT_PROJECT_TEAM_SIDE}
        can [:edit_status, :update_status], CertificationPath, certification_path_status: {id: CertificationPathStatus::STATUSES_AT_CERTIFIER_SIDE}
        can [:edit_max_review_count, :update_max_review_count], CertificationPath
      elsif user.gsas_trust_top_manager?
        can [:edit_status, :update_status], CertificationPath, certification_path_status: {id: CertificationPathStatus::APPROVING_BY_TOP_MANAGEMENT}
      elsif user.gsas_trust_manager?
        can [:edit_status, :update_status], CertificationPath, certification_path_status: {id: CertificationPathStatus::APPROVING_BY_MANAGEMENT}
      end
      # SchemeMix
      cannot :read, SchemeMix, certification_path: {certification_path_status: {id: CertificationPathStatus::ACTIVATING}}
      can :update, SchemeMix, certification_path: {certification_path_status: {id: CertificationPathStatus::ACTIVATING}, development_type: {mixable: true}}
      # SchemeMixCriterion
      cannot :read, SchemeMixCriterion, scheme_mix: {certification_path: {certification_path_status: {id: CertificationPathStatus::ACTIVATING}}}
      cannot :list, SchemeMixCriterion, scheme_mix: {certification_path: {certification_path_status: {id: CertificationPathStatus::ACTIVATING}}}
      # RequirementDatum
      cannot :read, RequirementDatum, scheme_mix_criteria: {scheme_mix: {certification_path: {certification_path_status: {id: CertificationPathStatus::ACTIVATING}}}}
      # SchemeCriterionText
      if user.gsas_trust_admin?
        can :crud, SchemeCriterionText
      end
      # Audit log
      can :index, AuditLog
      can :auditable_index, AuditLog
      can :auditable_index_comments, AuditLog
      can :auditable_create, AuditLog

      # Task
      can :read, Task
      can :count, Task
      # Tools controller
      can :manage, :tool
      # User controller
      can [:list_notifications,:update_notifications], User, id: user.id
      can :find_users_by_email, User
      # Reports controller
      can :certifiers_criteria, :report

      # Owner
      can [:index, :show], Owner

      # # Admins opt-out for specific abilities
      # cannot :apply_for_pcr, CertificationPath, pcr_track: true
      # cannot :apply_for_pcr, CertificationPath, certificate: {certificate_type: ['construction_type', Certificate.certificate_types[:construction_type], 'operations_type', Certificate.certificate_types[:operations_type]]}
      # cannot [:edit_status, :update_status], CertificationPath, certification_path_status: {id: CertificationPathStatus::STATUSES_AT_PROJECT_TEAM_SIDE }
      # cannot [:edit_status, :update_status], CertificationPath, certification_path_status: {id: CertificationPathStatus::STATUSES_AT_MANAGEMENT_SIDE}
      # cannot [:edit_status, :update_status], CertificationPath, certification_path_status: {id: CertificationPathStatus::STATUSES_COMPLETED}
      # cannot [:edit_project_team_responsibility, :allocate_project_team_responsibility], CertificationPath do |certification_path| !CertificationPathStatus::STATUSES_IN_SUBMISSION.include?(certification_path.certification_path_status_id) end
      # cannot [:edit_certifier_team_responsibility, :allocate_certifier_team_responsibility], CertificationPath do |certification_path| !CertificationPathStatus::STATUSES_IN_VERIFICATION.include?(certification_path.certification_path_status_id) end
      # cannot :update_achieved_score, SchemeMixCriterion do |scheme_mix_criterion| ![SchemeMixCriterion.statuses[:submitting], SchemeMixCriterion.statuses[:submitting_after_appeal]].include?(scheme_mix_criterion.status) end
      # cannot :update_achieved_score, SchemeMixCriterion do |scheme_mix_criterion| ![SchemeMixCriterion.statuses[:verifying], SchemeMixCriterion.statuses[:verifying_after_appeal]].include?(scheme_mix_criterion.status) end
      # cannot :refuse, RequirementDatum do |requirement_datum| requirement_datum.user_id != user.id end
    elsif user.system_admin?
      can :manage, :all
    else
      cannot :manage, :all
    end
  end
end
