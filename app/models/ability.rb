class Ability
  include CanCan::Ability

  def initialize(user, params = nil, request = nil)
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

    @project = get_project(request)
    certification_team_type = get_certification_team_type(request)

    if @project.present?
      if @project.design_and_build? && user.valid_design_build_cp_available?
        @service_provider_valid_licences = user&.valid_user_sp_design_build_licences
        @cp_valid_licences = user&.valid_user_design_build_licences

      elsif @project.construction_management? && user.valid_construction_management_cp_available?
        @service_provider_valid_licences = user&.valid_user_sp_construction_management_licences
        @cp_valid_licences = user&.valid_user_construction_management_licences

      elsif @project.operation?
        @service_provider_valid_licences = user&.valid_user_sp_operation_licences
        @cp_valid_licences = user&.valid_user_operation_licences
      end

    else
      if user.valid_cgp_or_cep_available?
        @service_provider_valid_licences = user&.valid_user_sp_licences
        @cp_valid_licences = user&.valid_user_licences
      end

    end

    @service_provider_valid_licences ||= AccessLicence.none
    @cp_valid_licences ||= AccessLicence.none

    @valid_checklist_licences = user.valid_checklist_licences

    alias_action :create, :read, :update, :destroy, :to => :crud

    # Some convenience variables to work with enums in conditions
    project_user_role_cgp_project_manager = [ProjectsUser.roles[:cgp_project_manager]]
    user_with_gsas_trust_admin = [User.roles[:gsas_trust_admin]]
    user_with_gsas_trust_manager = [User.roles[:gsas_trust_manager]]
    user_with_gsas_trust_top_manager = [User.roles[:gsas_trust_top_manager]]
    project_user_role_project_team_member = [ProjectsUser.roles[:project_team_member]]
    project_user_role_certification_manager = [ProjectsUser.roles[:certification_manager]]
    project_user_role_certifier = [ProjectsUser.roles[:certifier]]
    project_user_role_enterprise_client = [ProjectsUser.roles[:enterprise_client]]
    project_user_project_team_roles = project_user_role_cgp_project_manager | project_user_role_project_team_member
    project_user_gsas_trust_team_roles = project_user_role_certification_manager | project_user_role_certifier
    project_user_enterprise_client_roles = project_user_role_enterprise_client
    user_with_gsas_trust = user_with_gsas_trust_admin | user_with_gsas_trust_manager | user_with_gsas_trust_top_manager

    #   Certificate.certification_types
    certificate_certification_types_letter_of_conformance = [Certificate.certification_types[:letter_of_conformance]]
    certificate_certification_types_final_design_certificate = [Certificate.certification_types[:final_design_certificate]]
    certificate_certification_types_construction_certificate_stage1 = [Certificate.certification_types[:construction_certificate_stage1]]
    certificate_certification_types_construction_certificate_stage2 = [Certificate.certification_types[:construction_certificate_stage2]]
    certificate_certification_types_construction_certificate_stage3 = [Certificate.certification_types[:construction_certificate_stage3]]
    certificate_certification_types_operations_certificate = [Certificate.certification_types[:operations_certificate]]
    #   SchemeMixCriterion.statuses
    scheme_mix_criterion_status_submitting = [SchemeMixCriterion.statuses[:submitting], SchemeMixCriterion.statuses[:submitting_after_appeal]]
    scheme_mix_criterion_status_submitted = [SchemeMixCriterion.statuses[:submitted], SchemeMixCriterion.statuses[:submitted_after_appeal]]
    scheme_mix_criterion_status_screening = [SchemeMixCriterion.statuses[:submitted]]
    scheme_mix_criterion_status_verifying = [SchemeMixCriterion.statuses[:verifying], SchemeMixCriterion.statuses[:verifying_after_appeal]]
    scheme_mix_criterion_status_verified = [SchemeMixCriterion.statuses[:score_awarded], SchemeMixCriterion.statuses[:score_downgraded], SchemeMixCriterion.statuses[:score_upgraded], SchemeMixCriterion.statuses[:score_minimal]]
    scheme_mix_criterion_status_verified_after_appeal = [SchemeMixCriterion.statuses[:score_awarded_after_appeal], SchemeMixCriterion.statuses[:score_downgraded_after_appeal], SchemeMixCriterion.statuses[:score_upgraded_after_appeal], SchemeMixCriterion.statuses[:score_minimal_after_appeal]]
    scheme_mix_criterion_status_verifying_or_verified = scheme_mix_criterion_status_verifying | scheme_mix_criterion_status_verified | scheme_mix_criterion_status_verified_after_appeal
    # SchemeMixCriteriaDocument.statuses
    document_approved = [SchemeMixCriteriaDocument.statuses[:approved]]

    # Convenience conditions, to use within abilities
    @certficate_types_of_valid_user_licences = certficate_types_of_valid_user_licences
    
    active_user = { id: user.id, active: true }
    project_with_user_assigned = {projects_users: {user_id: user.id}}
    project_with_user_as_cgp_project_manager = { projects_users: {user: active_user, role: project_user_role_cgp_project_manager, certification_team_type: certification_team_type}, certificate_type: @certficate_types_of_valid_user_licences }
    project_with_user_as_project_team_member = {projects_users: {user: active_user, role: project_user_role_project_team_member, certification_team_type: certification_team_type}, certificate_type: @certficate_types_of_valid_user_licences }
    project_with_user_in_project_team = {projects_users: {user: active_user, role: project_user_project_team_roles, certification_team_type: certification_team_type}, certificate_type: @certficate_types_of_valid_user_licences }
    project_with_user_as_certification_manager = {projects_users: {user: active_user, role: project_user_role_certification_manager, certification_team_type: certification_team_type}}
    project_with_user_as_certifier = {projects_users: {user: active_user, role: project_user_role_certifier, certification_team_type: certification_team_type}}
    project_with_user_in_gsas_trust_team = {projects_users: {user: active_user, role: project_user_gsas_trust_team_roles}}
    project_with_user_as_enterprise_client = {projects_users: {user: active_user, role: project_user_enterprise_client_roles}}

    if user.type == 'ServiceProvider'
      users_with_service_provider = { user: { service_provider_id: user.id } }
    else
      users_with_service_provider = { user: { id: user.id } }
    end
   
    projects_users_with_service_provider = { projects_users: users_with_service_provider }

    schemes_array = { name: schemes_of_valid_user_licences }
    schemes_under_valid_licences = { scheme: schemes_array }

    # for read permissions
    read_project_with_user_as_cgp_project_manager = {projects_users: {user_id: user.id, role: project_user_role_cgp_project_manager}}
    read_project_with_user_as_project_team_member = {projects_users: {user_id: user.id, role: project_user_role_project_team_member}}
    read_project_with_user_in_project_team = {projects_users: {user_id: user.id, role: project_user_project_team_roles}}
    read_project_with_user_as_certification_manager = {projects_users: {user_id: user.id, role: project_user_role_certification_manager}}
    read_project_with_user_as_certifier = {projects_users: {user_id: user.id, role: project_user_role_certifier}}

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

    can [:show, :edit, :update], User, id: user.id
    can [:edit_service_provider, :update_service_provider], ServiceProvider, id: user.id

    if user.default_role?
      # Project controller
      can :read, Project, projects_users: {user_id: user.id}
      can [:download_location_plan, :download_site_plan, :download_design_brief, :download_project_narrative, :download_area_statement, :download_sustainability_features], Project, projects_users: {user_id: user.id}
      can :show_tools, Project, projects_users: {user_id: user.id}
      can :update, Project, projects_users: {user: active_user, role: project_user_role_cgp_project_manager}
      cannot :update, Project, projects_users: {user_id: user.id, role: project_user_role_cgp_project_manager}, certification_paths: {certification_path_status: {id: CertificationPathStatus::STATUSES_ACTIVATED}}

      if valid_user_associates?(user) && user.active?
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
      can :download_signed_certificate, CertificationPath, project: project_with_user_assigned, certification_path_status: {id: [CertificationPathStatus::CERTIFIED, CertificationPathStatus::CERTIFICATE_IN_PROCESS]}
      can [:new_detailed_certification_report, :create_detailed_certification_report], CertificationPath, certification_path_status: {id: [CertificationPathStatus::CERTIFIED, CertificationPathStatus::CERTIFICATE_IN_PROCESS]}, project: project_with_user_as_cgp_project_manager

      # Project team
      can :apply, CertificationPath, project: project_with_user_as_cgp_project_manager

      can :edit_status, CertificationPath.not_expired, certification_path_status: {id: CertificationPathStatus::STATUSES_AT_PROJECT_TEAM_SIDE}, project: project_with_user_as_cgp_project_manager, scheme_mixes: schemes_under_valid_licences
      can :update_status, CertificationPath.not_expired, certification_path_status: {id: CertificationPathStatus::STATUSES_AT_PROJECT_TEAM_SIDE}, project: project_with_user_as_cgp_project_manager, scheme_mixes: schemes_under_valid_licences
      can [:edit_project_team_responsibility_for_submittal, :allocate_project_team_responsibility_for_submittal], CertificationPath, project: project_with_user_as_cgp_project_manager, certification_path_status: {id: CertificationPathStatus::STATUSES_IN_SUBMISSION}, scheme_mixes: schemes_under_valid_licences
      # GSAS trust team
      can [:edit_status, :update_status], CertificationPath, certification_path_status: {id: CertificationPathStatus::STATUSES_AT_CERTIFIER_SIDE}, project: project_with_user_as_certification_manager
      can [:edit_certifier_team_responsibility_for_verification, :allocate_certifier_team_responsibility_for_verification], CertificationPath, project: project_with_user_as_certification_manager, certification_path_status: {id: CertificationPathStatus::STATUSES_IN_VERIFICATION}
      can [:edit_certifier_team_responsibility_for_screening, :allocate_certifier_team_responsibility_for_screening], CertificationPath, project: project_with_user_as_certification_manager, certification_path_status: {id: CertificationPathStatus::SCREENING}

      # SchemeMix controller
      can :read, SchemeMix, certification_path: {project: project_with_user_assigned, certification_path_status: {id: CertificationPathStatus::STATUSES_ACTIVATED}}
      # TODO ????????????
      #can :update, SchemeMix, certification_path: {project: project_with_user_as_cgp_project_manager, certification_path_status: {id: CertificationPathStatus::ACTIVATING}, development_type: {mixable: true}}

      can :update, SchemeMix, certification_path: { project: project_with_user_as_cgp_project_manager, certification_path_status: {id: CertificationPathStatus::ACTIVATING} }, scheme: schemes_array

      can [:create, :read], [ActualProjectImage, ProjectRenderingImage] , project: { certificate_type: [Certificate.certificate_types[:design_type], Certificate.certificate_types[:operations_type]] }, project: project_with_user_as_cgp_project_manager

      can :read, [ActualProjectImage, ProjectRenderingImage] , project: { certificate_type: [Certificate.certificate_types[:design_type], Certificate.certificate_types[:operations_type]] }, project: read_project_with_user_as_certification_manager

      # SchemeMixCriterion controller
      can [:read, :list], SchemeMixCriterion, scheme_mix: {certification_path: {project: read_project_with_user_as_cgp_project_manager, certification_path_status: {id: CertificationPathStatus::STATUSES_ACTIVATED}}}
      can [:read, :list], SchemeMixCriterion, scheme_mix: {certification_path: {project: project_with_user_in_gsas_trust_team, certification_path_status: {id: CertificationPathStatus::STATUSES_ACTIVATED}}}
      can [:read, :list], SchemeMixCriterion, scheme_mix: {certification_path: {project: project_with_user_as_enterprise_client, certification_path_status: {id: CertificationPathStatus::STATUSES_ACTIVATED}}}
      can [:read, :list], SchemeMixCriterion, scheme_mix: {certification_path: {project: read_project_with_user_as_project_team_member, certification_path_status: {id: CertificationPathStatus::STATUSES_ACTIVATED}}}, requirement_data: {user_id: user.id}
      can [:read, :list], SchemeMixCriterion, scheme_mix: {certification_path: {project: read_project_with_user_as_project_team_member, certification_path_status: {id: CertificationPathStatus::STATUSES_ACTIVATED}, show_all_criteria: true}}
      can :download_archive, SchemeMixCriterion, scheme_mix: {certification_path: {project: project_with_user_assigned, certification_path_status: {id: CertificationPathStatus::STATUSES_ACTIVATED}}}
      # Project team
      can [:edit_status, :update_status], SchemeMixCriterion, main_scheme_mix_criterion: nil, status: scheme_mix_criterion_status_submitting, scheme_mix: {certification_path: {certification_path_status: {id: CertificationPathStatus::STATUSES_IN_SUBMISSION}, project: project_with_user_as_cgp_project_manager}, scheme: schemes_array}
      # allows a submitted state, to be reset
      can [:edit_status, :update_status], SchemeMixCriterion, main_scheme_mix_criterion: nil, status: scheme_mix_criterion_status_submitted, scheme_mix: {certification_path: {certification_path_status: {id: CertificationPathStatus::STATUSES_IN_SUBMISSION}, project: project_with_user_as_cgp_project_manager}, scheme: schemes_array}
      # Managers can update scores depending on the status
      can :update_targeted_score, SchemeMixCriterion, main_scheme_mix_criterion: nil, status: scheme_mix_criterion_status_submitting, scheme_mix: {certification_path: {project: project_with_user_as_cgp_project_manager}, scheme: schemes_array}
      can :update_submitted_score, SchemeMixCriterion, main_scheme_mix_criterion: nil, status: scheme_mix_criterion_status_submitting, scheme_mix: {certification_path: {project: project_with_user_as_cgp_project_manager}, scheme: schemes_array}
      can :update_submitted_score, SchemeMixCriterion, main_scheme_mix_criterion: nil, status: scheme_mix_criterion_status_submitting, requirement_data: {user_id: user.id}, scheme_mix: {certification_path: {project: project_with_user_in_project_team}, scheme: schemes_array}
      can [:apply_pcr, :request_review], SchemeMixCriterion, main_scheme_mix_criterion: nil, status: [SchemeMixCriterion.statuses[:submitting]], scheme_mix: {certification_path: {certificate: {certification_type: [Certificate.certification_types[:letter_of_conformance], Certificate.certification_types[:final_design_certificate], Certificate.certification_types[:operations_certificate], Certificate.certification_types[:construction_certificate_stage1], Certificate.certification_types[:construction_certificate_stage2], Certificate.certification_types[:construction_certificate_stage3]]}, certification_path_status: {id: [CertificationPathStatus::SUBMITTING, CertificationPathStatus::SUBMITTING_AFTER_SCREENING]}, project: project_with_user_as_cgp_project_manager, pcr_track: true}, scheme: schemes_array}
      
      # Managers can update checklist depending on the status
      can :update_targeted_checklist, SchemeMixCriterionBox, scheme_mix_criterion: {main_scheme_mix_criterion: nil, status: scheme_mix_criterion_status_submitting, scheme_mix: {certification_path: {project: project_with_user_as_cgp_project_manager}, scheme: schemes_array}}
      can :update_submitted_checklist, SchemeMixCriterionBox, scheme_mix_criterion: {main_scheme_mix_criterion: nil, status: scheme_mix_criterion_status_submitting, scheme_mix: {certification_path: {project: project_with_user_as_cgp_project_manager}, scheme: schemes_array}}

      can :update_targeted_checklist, SchemeMixCriterionBox, scheme_mix_criterion: {main_scheme_mix_criterion: nil, status: scheme_mix_criterion_status_submitting, certifier_id: user.id, scheme_mix: {certification_path: {project: project_with_user_in_project_team}, scheme: schemes_array}}
      can :update_submitted_checklist, SchemeMixCriterionBox, scheme_mix_criterion: {main_scheme_mix_criterion: nil, status: scheme_mix_criterion_status_submitting, certifier_id: user.id, scheme_mix: {certification_path: {project: project_with_user_in_project_team}, scheme: schemes_array}}
      
      can :update_achieved_checklist, SchemeMixCriterionBox, scheme_mix_criterion: { main_scheme_mix_criterion: nil, status: scheme_mix_criterion_status_verifying, scheme_mix: {certification_path: {project: project_with_user_as_certification_manager}}}
      can :update_achieved_checklist, SchemeMixCriterionBox, scheme_mix_criterion: { main_scheme_mix_criterion: nil, status: scheme_mix_criterion_status_verifying, certifier_id: user.id, scheme_mix: {certification_path: {project: project_with_user_in_gsas_trust_team}}}
      
      # GSAS trust team
      can [:edit_status, :update_status], SchemeMixCriterion, main_scheme_mix_criterion: nil, status: scheme_mix_criterion_status_verifying, scheme_mix: {certification_path: {certification_path_status: {id: CertificationPathStatus::STATUSES_IN_VERIFICATION}, project: project_with_user_as_certification_manager}}
      can [:edit_status, :update_status], SchemeMixCriterion, main_scheme_mix_criterion: nil, status: scheme_mix_criterion_status_verifying, certifier_id: user.id, scheme_mix: {certification_path: {certification_path_status: {id: CertificationPathStatus::STATUSES_IN_VERIFICATION}, project: project_with_user_in_gsas_trust_team}}
      # allows a submitted state, to be reset
      can [:edit_status, :update_status], SchemeMixCriterion, main_scheme_mix_criterion: nil, status: scheme_mix_criterion_status_verified, scheme_mix: {certification_path: {certification_path_status: {id: CertificationPathStatus::VERIFYING}, project: project_with_user_as_certification_manager}}
      can [:edit_status, :update_status], SchemeMixCriterion, main_scheme_mix_criterion: nil, status: scheme_mix_criterion_status_verified, certifier_id: user.id, scheme_mix: {certification_path: {certification_path_status: {id: CertificationPathStatus::VERIFYING}, project: project_with_user_in_gsas_trust_team}}
      # allows a submitted state, to be reset
      can [:edit_status, :update_status], SchemeMixCriterion, main_scheme_mix_criterion: nil, status: scheme_mix_criterion_status_verified_after_appeal, scheme_mix: {certification_path: {certification_path_status: {id: CertificationPathStatus::VERIFYING_AFTER_APPEAL}, project: project_with_user_as_certification_manager}}
      can [:edit_status, :update_status], SchemeMixCriterion, main_scheme_mix_criterion: nil, status: scheme_mix_criterion_status_verified_after_appeal, certifier_id: user.id, scheme_mix: {certification_path: {certification_path_status: {id: CertificationPathStatus::VERIFYING_AFTER_APPEAL}, project: project_with_user_in_gsas_trust_team}}

      # Managers can update scores depending on the status
      can :update_achieved_score, SchemeMixCriterion, main_scheme_mix_criterion: nil, status: scheme_mix_criterion_status_verifying, scheme_mix: {certification_path: {project: project_with_user_as_certification_manager}}
      can :update_achieved_score, SchemeMixCriterion, main_scheme_mix_criterion: nil, status: scheme_mix_criterion_status_verifying, certifier_id: user.id, scheme_mix: {certification_path: {project: project_with_user_in_gsas_trust_team}}
      can :assign_certifier, SchemeMixCriterion, main_scheme_mix_criterion: nil, status: scheme_mix_criterion_status_verifying, scheme_mix: {certification_path: {project: project_with_user_as_certification_manager}}
      can :assign_certifier, SchemeMixCriterion, main_scheme_mix_criterion: nil, status: scheme_mix_criterion_status_screening, scheme_mix: {certification_path: {project: project_with_user_as_certification_manager, certification_path_status_id: CertificationPathStatus::SCREENING}}
      can :assign_certifier, SchemeMixCriterion, main_scheme_mix_criterion: nil, in_review: true, scheme_mix: {certification_path: {project: project_with_user_as_certification_manager}}
      can [:provide_review_comment, :add_review_comment], SchemeMixCriterion, main_scheme_mix_criterion: nil, in_review: true, scheme_mix: {certification_path: {project: project_with_user_as_certification_manager}}
      can [:provide_draft_review_comment, :add_draft_review_comment], SchemeMixCriterion, main_scheme_mix_criterion: nil, in_review: true, certifier_id: user.id, scheme_mix: {certification_path: {project: project_with_user_as_certifier}}
      can :update_incentive_scored, SchemeMixCriterion, main_scheme_mix_criterion: nil, status: scheme_mix_criterion_status_verifying, scheme_mix: {certification_path: {project: project_with_user_as_certification_manager}}
      can :update_incentive_scored, SchemeMixCriterion, main_scheme_mix_criterion: nil, status: scheme_mix_criterion_status_verifying, certifier_id: user.id, scheme_mix: {certification_path: {project: project_with_user_in_gsas_trust_team}}
      can :update_incentive_scored, SchemeMixCriterionIncentive, scheme_mix_criterion: {main_scheme_mix_criterion: nil, status: scheme_mix_criterion_status_verifying, scheme_mix: {certification_path: {project: project_with_user_as_certification_manager}}}
      can :update_incentive_scored, SchemeMixCriterionIncentive, scheme_mix_criterion: {main_scheme_mix_criterion: nil, status: scheme_mix_criterion_status_verifying, certifier_id: user.id, scheme_mix: {certification_path: {project: project_with_user_in_gsas_trust_team}}}
      can :screen, SchemeMixCriterion, main_scheme_mix_criterion: nil, screened: false, scheme_mix: {certification_path: {certification_path_status: {id: CertificationPathStatus::SCREENING}, project: project_with_user_in_gsas_trust_team}}
      can :update, SchemeMixCriterionEpl, scheme_mix_criterion: {main_scheme_mix_criterion: nil, status: scheme_mix_criterion_status_verifying, scheme_mix: {certification_path: {project: project_with_user_as_certification_manager}}}
      can :update, SchemeMixCriterionWpl, scheme_mix_criterion: {main_scheme_mix_criterion: nil, status: scheme_mix_criterion_status_verifying, scheme_mix: {certification_path: {project: project_with_user_as_certification_manager}}}
      can :read, SchemeMixCriterionEpl, scheme_mix_criterion: {status: scheme_mix_criterion_status_verifying_or_verified, scheme_mix: {certification_path: {project: read_project_with_user_as_certification_manager}}}
      can :read, SchemeMixCriterionEpl, scheme_mix_criterion: {status: scheme_mix_criterion_status_verifying_or_verified, scheme_mix: {certification_path: {project: project_with_user_as_enterprise_client}}}
      can :read, SchemeMixCriterionWpl, scheme_mix_criterion: {status: scheme_mix_criterion_status_verifying_or_verified, scheme_mix: {certification_path: {project: read_project_with_user_as_certification_manager}}}
      can :read, SchemeMixCriterionWpl, scheme_mix_criterion: {status: scheme_mix_criterion_status_verifying_or_verified, scheme_mix: {certification_path: {project: project_with_user_as_enterprise_client}}}
      can :epc_matches_energy_suite, SchemeMixCriterion, status: scheme_mix_criterion_status_verifying, scheme_mix: {certification_path: {project: project_with_user_in_gsas_trust_team}}
      can :upload_epc_matches_document, SchemeMixCriterion, scheme_mix: {certification_path: {project: project_with_user_in_gsas_trust_team}}

      # RequirementDatum controller
      can :read, RequirementDatum, scheme_mix_criteria: {scheme_mix: {certification_path: {project: project_with_user_assigned, certification_path_status: {id: CertificationPathStatus::STATUSES_ACTIVATED}}}}
      # Project team
      can :update, RequirementDatum, scheme_mix_criteria: {status: scheme_mix_criterion_status_submitting, scheme_mix: {certification_path: {project: project_with_user_as_cgp_project_manager}, scheme: schemes_array}}
      can :update_status, RequirementDatum, user_id: user.id, scheme_mix_criteria: {status: scheme_mix_criterion_status_submitting, scheme_mix: {certification_path: {project: project_with_user_in_project_team}, scheme: schemes_array}}
      can :refuse, RequirementDatum, user_id: user.id, scheme_mix_criteria: {status: scheme_mix_criterion_status_submitting, scheme_mix: {certification_path: {project: project_with_user_in_project_team}, scheme: schemes_array}}

      # Document controller
      can :read, Document, scheme_mix_criteria_documents: { scheme_mix_criterion: {scheme_mix: {certification_path: {project: project_with_user_assigned}}}}
      # Project team
      can :create, Document, scheme_mix_criteria_documents: { scheme_mix_criterion: {main_scheme_mix_criterion: nil, status: scheme_mix_criterion_status_submitting, scheme_mix: {certification_path: {project: project_with_user_in_project_team}, scheme: schemes_array}}}
      can :destroy, Document, scheme_mix_criteria_documents: {scheme_mix_criterion: {main_scheme_mix_criterion: nil, status: scheme_mix_criterion_status_submitting, scheme_mix: {certification_path: {project: project_with_user_as_cgp_project_manager}, scheme: schemes_array}}}, certification_path_status_id: @certification_path&.certification_path_status_id

      # CertificationPathDocument controller
      can :read, CertificationPathDocument, certification_path: {project: project_with_user_assigned}
      can :create, CgpCertificationPathDocument, certification_path: {project: project_with_user_as_cgp_project_manager, scheme_mixes: schemes_under_valid_licences}
      can :destroy, CgpCertificationPathDocument, certification_path: {project: project_with_user_as_cgp_project_manager, scheme_mixes: schemes_under_valid_licences}, certification_path_status_id: @certification_path&.certification_path_status_id

      can [:create, :destroy], CertifierCertificationPathDocument, certification_path: {project: project_with_user_as_certification_manager}

      # SchemeMixCriteriaDocument controller
      # Project team
      can :read, SchemeMixCriteriaDocument, scheme_mix_criterion: {scheme_mix: {certification_path: {project: read_project_with_user_in_project_team}}}
      can [:update_status, :edit_status], SchemeMixCriteriaDocument, scheme_mix_criterion: {status: scheme_mix_criterion_status_submitting, scheme_mix: {certification_path: {project: project_with_user_as_cgp_project_manager}, scheme: schemes_array}}
      can [:create_link, :new_link], SchemeMixCriteriaDocument, scheme_mix_criterion: {status: scheme_mix_criterion_status_submitting, scheme_mix: {certification_path: {project: project_with_user_in_project_team}, scheme: schemes_array}}, document: { certification_path_status_id: @certification_path&.certification_path_status_id }
      can [:unlink, :destroy_link], SchemeMixCriteriaDocument, scheme_mix_criterion: {status: scheme_mix_criterion_status_submitting, scheme_mix: {certification_path: {project: project_with_user_as_cgp_project_manager}, scheme: schemes_array}}, document: { certification_path_status_id: @certification_path&.certification_path_status_id }
      # GSAS trust team
      can :read, SchemeMixCriteriaDocument, status: document_approved, scheme_mix_criterion: {scheme_mix: {certification_path: {project: project_with_user_in_gsas_trust_team}}}
      can :read, SchemeMixCriteriaDocument, scheme_mix_criterion: {in_review: true, scheme_mix: {certification_path: {project: project_with_user_in_gsas_trust_team}}}
      # Enterprise clients
      can :read, SchemeMixCriteriaDocument, status: document_approved, scheme_mix_criterion: {scheme_mix: {certification_path: {project: project_with_user_as_enterprise_client}}}

      # AuditLog controller
      can [:index, :auditable_index, :auditable_index_comments, :download_attachment, :export], AuditLog, audit_log_visibility_id: AuditLogVisibility::PUBLIC, project: project_with_user_assigned
      can [:index, :auditable_index, :auditable_index_comments, :download_attachment, :export], AuditLog, project: project_with_user_in_gsas_trust_team
      can :auditable_create, AuditLog #TODO:, project: project_with_user_assigned

      can [:link_smc_comments_form, :link_smc_comments],  AuditLog, auditable: {scheme_mix: {certification_path: {project: project_with_user_as_certification_manager}}}
      can [:unlink_smc_comments_form, :unlink_smc_comments],  AuditLog, auditable: {scheme_mix: {certification_path: {project: project_with_user_as_certification_manager}}}

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

      # Archive
      can :show, Archive, user_id: user.id

      # Visualisation Tool
      if user.gord_employee?
        can :show, 'visualisation_tool'
      end
    elsif user.gsas_trust_admin? || user.gsas_trust_manager? || user.gsas_trust_top_manager?
      can :read, :all
      can [:index, :auditable_index, :auditable_index_comments, :download_attachment, :export], AuditLog, attachment_file: true
      # Project
      can [:download_location_plan, :download_site_plan, :download_design_brief, :download_project_narrative, :download_area_statement, :download_sustainability_features], Project
      can :show_tools, Project
      can :update, SchemeMixCriterionEpl, scheme_mix_criterion: {main_scheme_mix_criterion: nil, status: scheme_mix_criterion_status_verifying}
      can :update, SchemeMixCriterionWpl, scheme_mix_criterion: {main_scheme_mix_criterion: nil, status: scheme_mix_criterion_status_verifying}
      can :epc_matches_energy_suite, SchemeMixCriterion, status: scheme_mix_criterion_status_verifying
      can :upload_epc_matches_document, SchemeMixCriterion

      can :select_service_provider, User

      if user.gsas_trust_admin?
        can [:create, :destroy], [ActualProjectImage, ProjectRenderingImage]
        can :update, Project
        can [:confirm_destroy, :destroy], Project # Be careful with this!
        can :update_incentive_scored, SchemeMixCriterion
        can [:new_detailed_certification_report, :create_detailed_certification_report], CertificationPath, certification_path_status: {id: [CertificationPathStatus::CERTIFIED, CertificationPathStatus::CERTIFICATE_IN_PROCESS]}
      end
      # Project Users
      # can :list_users_sharing_projects, ProjectsUser
      # can :list_projects, ProjectsUser
      if user.gsas_trust_admin?
        can :crud, ProjectsUser, role: project_user_project_team_roles
        can :crud, ProjectsUser, role: project_user_gsas_trust_team_roles
        can :crud, ProjectsUser, role: project_user_enterprise_client_roles
        # You can't add yourself
        cannot :create, ProjectsUser, user_id: user.id
      end
      # Certification Path
      can :list, CertificationPath
      can :apply_for_pcr, CertificationPath, pcr_track: false, certificate: {certification_type: [Certificate.certification_types[:letter_of_conformance], Certificate.certification_types[:final_design_certificate], Certificate.certification_types[:operations_certificate], Certificate.certification_types[:construction_certificate_stage1], Certificate.certification_types[:construction_certificate_stage2], Certificate.certification_types[:construction_certificate_stage3]]}
      can :cancel_pcr, CertificationPath, pcr_track: true, certificate: {certification_type: [Certificate.certification_types[:letter_of_conformance], Certificate.certification_types[:final_design_certificate], Certificate.certification_types[:operations_certificate], Certificate.certification_types[:construction_certificate_stage1], Certificate.certification_types[:construction_certificate_stage2], Certificate.certification_types[:construction_certificate_stage3]]}
      can :download_coverletter_report, CertificationPath, certification_path_status: {id: [CertificationPathStatus::CERTIFIED, CertificationPathStatus::CERTIFICATE_IN_PROCESS]}, certificate: {certification_type: Certificate.certification_types[:letter_of_conformance]}
      can :download_detailed_certificate_report, CertificationPath, certification_path_status: {id: [CertificationPathStatus::CERTIFIED, CertificationPathStatus::CERTIFICATE_IN_PROCESS]}, certification_path_report: { is_released: true }

      # User can download archive if and only if user is chairman(gsas_trust_top_manager) and project team member
      if  user.gsas_trust_top_manager?
        can :download_archive, CertificationPath
      end
      
      can :download_signed_certificate, CertificationPath, certification_path_status: {id: [CertificationPathStatus::CERTIFIED, CertificationPathStatus::CERTIFICATE_IN_PROCESS]}
      if user.gsas_trust_admin?
        can [:edit_main_scheme_mix, :update_main_scheme_mix], CertificationPath, certification_path_status: {id: CertificationPathStatus::ACTIVATING}, development_type: {mixable: true}
        can [:edit_status, :update_status], CertificationPath, certification_path_status: {id: CertificationPathStatus::STATUSES_AT_ADMIN_SIDE}
        can [:edit_status, :update_status], CertificationPath, certification_path_status: {id: CertificationPathStatus::STATUSES_AT_PROJECT_TEAM_SIDE}
        can [:edit_status, :update_status], CertificationPath, certification_path_status: {id: CertificationPathStatus::STATUSES_AT_CERTIFIER_SIDE}
        can [:edit_max_review_count, :update_max_review_count], CertificationPath
        can [:edit_expires_at, :update_expires_at], CertificationPath
        can [:confirm_destroy, :destroy], CertificationPath # Be careful with this!
        can [:confirm_deny, :deny], CertificationPath, certification_path_status: {id: CertificationPathStatus::STATUSES_IN_PROGRESS}
        can [:update_signed_certificate, :remove_signed_certificate], CertificationPath, certification_path_status: {id: [CertificationPathStatus::CERTIFIED, CertificationPathStatus::CERTIFICATE_IN_PROCESS]}
      elsif user.gsas_trust_top_manager?
        can [:edit_status, :update_status], CertificationPath, certification_path_status: {id: CertificationPathStatus::APPROVING_BY_TOP_MANAGEMENT}
      elsif user.gsas_trust_manager?
        can [:edit_status, :update_status], CertificationPath, certification_path_status: {id: CertificationPathStatus::APPROVING_BY_MANAGEMENT}
      end
      # SchemeMix
      cannot :read, SchemeMix, certification_path: {certification_path_status: {id: CertificationPathStatus::ACTIVATING}}
      can :update, SchemeMix, certification_path: {certification_path_status: {id: CertificationPathStatus::ACTIVATING}, development_type: {mixable: true}}
      can :download_scores_report, SchemeMix, certification_path: {certification_path_status: {id: [CertificationPathStatus::CERTIFIED, CertificationPathStatus::CERTIFICATE_IN_PROCESS]}, certificate: {certification_type: Certificate.certification_types[:letter_of_conformance]}}
      # SchemeMixCriterion
      can [:read, :list], SchemeMixCriterion
      cannot :read, SchemeMixCriterion, scheme_mix: {certification_path: {certification_path_status: {id: CertificationPathStatus::ACTIVATING}}}
      cannot :list, SchemeMixCriterion, scheme_mix: {certification_path: {certification_path_status: {id: CertificationPathStatus::ACTIVATING}}}
      if user.gsas_trust_admin?
        can :update_targeted_score, SchemeMixCriterion
        can :update_submitted_score, SchemeMixCriterion
        can :update_achieved_score, SchemeMixCriterion
      end
      can :download_archive, SchemeMixCriterion, scheme_mix: {certification_path: {certification_path_status: {id: CertificationPathStatus::STATUSES_ACTIVATED}}}
      # RequirementDatum
      cannot :read, RequirementDatum, scheme_mix_criteria: {scheme_mix: {certification_path: {certification_path_status: {id: CertificationPathStatus::ACTIVATING}}}}
      if user.gsas_trust_admin?
        # Document
        can [:create, :destroy], Document
        # SchemeMixCriteriaDocument
        can [:update_status, :edit_status, :create_link, :new_link, :unlink, :destroy_link], SchemeMixCriteriaDocument
        # SchemeCriterion
        can :manage, SchemeCriterion
        # SchemeCriterionText
        can :manage, SchemeCriterionText
        # Requirement
        can :manage, Requirement
        # SchemeCategory
        can :manage, SchemeCategory
        # Scheme
        can :manage, Scheme
        # CertificationPath advance status even when there are CM 2.1 Issue 3.0 criteria of categories E and W with score 0
        can :edit_status_low_score, CertificationPath
      end

      # Audit log
      can [:index, :auditable_index, :auditable_index_comments, :auditable_create, :link_smc_comments_form, :link_smc_comments, :unlink_smc_comments_form, :unlink_smc_comments, :download_attachment, :export], AuditLog

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

      # Archive
      can :show, Archive, user_id: user.id

      # # Admins opt-out for specific abilities
      # cannot :apply_for_pcr, CertificationPath, pcr_track: true
      # cannot :apply_for_pcr, CertificationPath, certificate: {certificate_type: [Certificate.certificate_types[:construction_type], Certificate.certificate_types[:operations_type]]}
      # cannot [:edit_status, :update_status], CertificationPath, certification_path_status: {id: CertificationPathStatus::STATUSES_AT_PROJECT_TEAM_SIDE }
      # cannot [:edit_status, :update_status], CertificationPath, certification_path_status: {id: CertificationPathStatus::STATUSES_AT_MANAGEMENT_SIDE}
      # cannot [:edit_status, :update_status], CertificationPath, certification_path_status: {id: CertificationPathStatus::STATUSES_COMPLETED}
      # cannot [:edit_project_team_responsibility_for_submittal, :allocate_project_team_responsibility_for_submittal], CertificationPath do |certification_path| !CertificationPathStatus::STATUSES_IN_SUBMISSION.include?(certification_path.certification_path_status_id) end
      # cannot [:edit_certifier_team_responsibility_for_verification, :allocate_certifier_team_responsibility_for_verification], CertificationPath do |certification_path| !CertificationPathStatus::STATUSES_IN_VERIFICATION.include?(certification_path.certification_path_status_id) end
      # cannot :update_achieved_score, SchemeMixCriterion do |scheme_mix_criterion| ![SchemeMixCriterion.statuses[:submitting], SchemeMixCriterion.statuses[:submitting_after_appeal]].include?(scheme_mix_criterion.status) end
      # cannot :update_achieved_score, SchemeMixCriterion do |scheme_mix_criterion| ![SchemeMixCriterion.statuses[:verifying], SchemeMixCriterion.statuses[:verifying_after_appeal]].include?(scheme_mix_criterion.status) end
      # cannot :refuse, RequirementDatum do |requirement_datum| requirement_datum.user_id != user.id end
    elsif user.document_controller?
      can :read, :all
      can :download_signed_certificate, CertificationPath, certification_path_status: { id: [CertificationPathStatus::CERTIFIED, CertificationPathStatus::CERTIFICATE_IN_PROCESS] }
      can [:download_location_plan, :download_site_plan, :download_design_brief, :download_project_narrative, :download_area_statement, :download_sustainability_features], Project
      can :download_detailed_certificate_report, CertificationPath, certification_path_status: {id: [CertificationPathStatus::CERTIFIED, CertificationPathStatus::CERTIFICATE_IN_PROCESS]}, certification_path_report: { is_released: true }
      cannot :read, AuditLog
      can [:new_detailed_certification_report, :create_detailed_certification_report], CertificationPath, certification_path_status: {id: [CertificationPathStatus::CERTIFIED, CertificationPathStatus::CERTIFICATE_IN_PROCESS]}
    elsif user.system_admin?
      can :manage, :all
    elsif user.record_checker?
      can :index, Project
      can :read, Project
      can :read, CertificationPath
      can :read, SchemeMix
      can :read, SchemeMixCriterion
    elsif user.users_admin?
      # Task
      can :read, Task
      can :count, Task

      can [:show, :edit, :update, :index], User
      can [:edit_service_provider, :update_service_provider], ServiceProvider
    elsif user.service_provider?
      can :read, Project, projects_users: users_with_service_provider
      can :read, ProjectsUser, project: projects_users_with_service_provider
      can :read, CertificationPath, project: projects_users_with_service_provider
      can :read, [SchemeMix, CertificationPathDocument], certification_path: { project: projects_users_with_service_provider }
      can :read, [ActualProjectImage, ProjectRenderingImage] , project: projects_users_with_service_provider
      can :read, SchemeMixCriterion, scheme_mix: {certification_path: {project: projects_users_with_service_provider}}
      can :read, [SchemeMixCriterionEpl, SchemeMixCriterionWpl, SchemeMixCriteriaDocument], scheme_mix_criterion: { scheme_mix: {certification_path: {project: projects_users_with_service_provider}}}
      can :read, RequirementDatum, scheme_mix_criteria: { scheme_mix: {certification_path: {project: projects_users_with_service_provider}}}
      can :read, Document, scheme_mix_criteria_documents: { scheme_mix_criterion: {scheme_mix: {certification_path: {project: projects_users_with_service_provider}}}}
      can :read, User, service_provider_id: user.id
    else
      cannot :manage, :all
    end
  end

  private

  def certficate_types_of_valid_user_licences
    certification_path_assessment_method =  if @certification_path.present?
                                              [@certification_path&.certification_path_method&.assessment_method, 3]
                                            else
                                              [
                                                Licence.applicabilities[:star_rating],
                                                Licence.applicabilities[:check_list],
                                                Licence.applicabilities[:both]
                                              ]
                                            end

    # assessment methods / Applicabilities under valid licences.
    service_provider_valid_licences_certificate_types = @service_provider_valid_licences.where("licences.applicability IN (:applicability)", applicability: certification_path_assessment_method).pluck("licences.certificate_type")
    cp_valid_licences_certificate_types = @cp_valid_licences.where("licences.applicability IN (:applicability)", applicability: certification_path_assessment_method).pluck("licences.certificate_type")

    allowed_certificate_types = service_provider_valid_licences_certificate_types & cp_valid_licences_certificate_types

    # for checklist licences, service provider licences verification not needed.
    valid_checklist_licences_certificate_type = @valid_checklist_licences.pluck("licences.certificate_type")

    if (@certification_path.present? && @certification_path.is_checklist_method?) || !@certification_path.present?
      allowed_certificate_types.push(*valid_checklist_licences_certificate_type)
    end

    return (allowed_certificate_types).uniq
  end

  def schemes_of_valid_user_licences
    schemes = @service_provider_valid_licences.pluck("licences.schemes").flatten.uniq

    # for checklist licences, service provider licences verification not needed.
    if @certification_path.present? && @certification_path.is_checklist_method? && @valid_checklist_licences.present?
      schemes = @certification_path&.development_type&.schemes&.pluck(:name).uniq
    end

    return schemes
  end

  def get_project(request = nil)
    return nil unless request.present?
    
    path = request.path
    path_array = path.split('/')
    project = nil

    begin
      project_id_index = path_array.index("projects")
      if project_id_index.present?
        project_id = path_array[project_id_index.to_i + 1]
        if project_id.present?
          project = Project.find(project_id.to_i)
        end
      end
    rescue => exception
      project = nil
    end

    return project
  end

  def get_certification_team_type(request = nil)
    all_certification_team_types = ProjectsUser.certification_team_types.values

    return all_certification_team_types unless request.present?
    
    path = request.path
    path_array = path.split('/')
    
    begin
      certificate_path_id_index = path_array.index("certificates")
      value = if certificate_path_id_index.present?
                certificate_path_id = path_array[certificate_path_id_index.to_i + 1]
                if certificate_path_id.to_i.to_s
                  @certification_path = CertificationPath.find(certificate_path_id.to_i)
                  if @certification_path.is_design_loc?
                    ProjectsUser.certification_team_types["Letter of Conformance"]
                  elsif @certification_path.is_design_fdc?
                    ProjectsUser.certification_team_types["Final Design Certificate"]
                  else
                    ProjectsUser.certification_team_types["Other"]
                  end
                else
                  all_certification_team_types
                end
              else
                all_certification_team_types
              end
      return value

    rescue => exception
      value = if @project.present?
                if @project.design_and_build?
                  [ProjectsUser.certification_team_types["Letter of Conformance"], ProjectsUser.certification_team_types["Final Design Certificate"]]
                else
                  ProjectsUser.certification_team_types["Other"]
                end
              else
                all_certification_team_types
              end
      return value
    end
  end

  def is_read_action?(params)
    read_actions = ["index", "show", "show_tools", "list"]
    read_actions.include?(params["action"]) rescue true
  end

  def valid_user_associates?(user)
    # User and Service Provider of user must have atleast one valid licence, Service Provider must have atleast one valid CGP & CEP.
    # for checklist licences, service provider licences verification not needed.

    user.valid_checklist_licences.present? || 
    user.allowed_certification_types.present?
  end
end
