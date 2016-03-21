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
    #   User Roles
    user_role_assessor = ['assessor', User.roles[:assessor]]
    user_role_certifier = ['certifier', User.roles[:certifier]]
    user_role_enterprise_client = ['enterprise_client', User.roles[:enterprise_client]]
    user_role_gord_admin = ['gord_admin', User.roles[:gord_admin]]
    user_role_gord_manager = ['gord_manager', User.roles[:gord_manager]]
    user_role_gord_top_manager = ['gord_top_manager', User.roles[:gord_top_manager]]
    #   ProjectUser Roles
    project_user_role_project_manager = ['project_manager', ProjectsUser.roles[:project_manager]]
    project_user_role_project_team_member = ['project_team_member', ProjectsUser.roles[:project_team_member]]
    project_user_role_certifier_manager = ['certifier_manager', ProjectsUser.roles[:certifier_manager]]
    project_user_role_certifier = ['certifier', ProjectsUser.roles[:certifier]]
    project_user_role_enterprise_client = ['enterprise_client', ProjectsUser.roles[:enterprise_client]]
    project_user_assessor_roles = project_user_role_project_manager | project_user_role_project_team_member
    project_user_certifier_roles = project_user_role_certifier_manager | project_user_role_certifier
    project_user_enterprise_client_roles = project_user_role_enterprise_client
    #   SchemeMixCriterion.statuses
    scheme_mix_criterion_status_submitting = ['submitting', SchemeMixCriterion.statuses[:submitting], 'submitting_after_appeal', SchemeMixCriterion.statuses[:submitting_after_appeal]]
    scheme_mix_criterion_status_submitted = ['submitted', SchemeMixCriterion.statuses[:submitted], 'submitted_after_appeal', SchemeMixCriterion.statuses[:submitted_after_appeal]]
    scheme_mix_criterion_status_verifying = ['verifying', SchemeMixCriterion.statuses[:verifying], 'verifying_after_appeal', SchemeMixCriterion.statuses[:verifying_after_appeal]]
    #scheme_mix_criterion_status_verified = ['submitted_score_achieved', SchemeMixCriterion.statuses[:submitted_score_achieved], 'submitted_score_not_achieved', SchemeMixCriterion.statuses[:submitted_score_not_achieved], 'submitted_score_achieved_after_appeal', SchemeMixCriterion.statuses[:submitted_score_achieved_after_appeal], 'submitted_score_not_achieved_after_appeal', SchemeMixCriterion.statuses[:submitted_score_not_achieved_after_appeal]]
    #   SchemeMixCriteriaDocument.statuses
    document_approved = ['approved', SchemeMixCriteriaDocument.statuses[:approved]]

    # Convenience conditions, to use within abilities
    project_with_user_assigned = {projects_users: {user_id: user.id}}
    project_with_user_as_project_manager = {projects_users: {user_id: user.id, role: project_user_role_project_manager}}
    project_with_user_as_assessor = {projects_users: {user_id: user.id, role: project_user_assessor_roles}}
    project_with_user_as_certifier_manager = {projects_users: {user_id: user.id, role: project_user_role_certifier_manager}}
    project_with_user_as_certifier = {projects_users: {user_id: user.id, role: project_user_certifier_roles}}

    # ------------------------------------------------------------------------------------------------------------
    # There are 3 types of user roles:
    #   - USERS, can see ONLY projects they are linked with
    #     - assessor
    #     - certifier
    #     - enterprise_client
    #   - ADMIN, can see ALL projects, without explicitly being linked to it
    #     - gord_admin
    #     - gord_manager
    #     - gord_top_mananager
    #   - SYSTEM, can do anything, only needed for testing or emergencies!
    #     - system_admin
    # ------------------------------------------------------------------------------------------------------------
    if user.assessor? || user.certifier? || user.enterprise_client?
      # Project controller
      can :read, Project, projects_users: {user_id: user.id}
      can [:download_location_plan, :download_site_plan, :download_design_brief, :download_project_narrative], Project, projects_users: {user_id: user.id}
      can :show_tools, Project, projects_users: {user_id: user.id}
      if user.assessor?
        can :create, Project, owner_id: user.id
        can :update, Project, projects_users: {user_id: user.id, role: project_user_role_project_manager}
      end

      # ProjectsUsers controller
      can :read, ProjectsUser, role: project_user_assessor_roles, project: project_with_user_as_assessor
      can :read, ProjectsUser, role: project_user_certifier_roles, project: project_with_user_as_certifier
      can :available, ProjectsUser, project: project_with_user_assigned
      # can :list_users_sharing_projects, ProjectsUser
      # can :list_projects, ProjectsUser

      if user.assessor?
        can :crud, ProjectsUser, role: project_user_assessor_roles, project: project_with_user_as_project_manager
      end
      if user.certifier?
        can :crud, ProjectsUser, role: project_user_certifier_roles, project: project_with_user_as_certifier_manager
      end
      # only the project owner, can make another project_manager the project owner
      can :make_owner, ProjectsUser do |projects_user|
        projects_user.project.owner_id == user.id && projects_user.project_manager?
      end
      # The project_owner details can't be changed, first make another project_manager the owner
      cannot [:create, :update, :destroy, :make_owner], ProjectsUser do |projects_user|
        projects_user.project.owner_id == projects_user.user_id
      end
      # You can't add yourself
      cannot :create, ProjectsUser, user_id: user.id

      # CertificationPath controller
      can :read, CertificationPath, project: project_with_user_assigned
      can :list, CertificationPath, project: project_with_user_assigned
      can [:download_certificate, :download_certificate_coverletter, :download_scores_report], CertificationPath, project: project_with_user_assigned
      can :download_archive, CertificationPath, project: project_with_user_assigned
      if user.assessor?
        can :apply, CertificationPath, project: project_with_user_as_project_manager
        can :apply_for_pcr, CertificationPath, pcr_track: false, project: project_with_user_as_project_manager, certificate: {certificate_type: ['design_type', Certificate.certificate_types[:design_type]]}
        can [:edit_status, :update_status], CertificationPath, certification_path_status: {id: CertificationPathStatus::STATUSES_AT_ASSESSOR_SIDE}, project: project_with_user_as_project_manager
        can [:edit_project_team_responsibility, :allocate_project_team_responsibility], CertificationPath, project: project_with_user_as_project_manager, certification_path_status: {id: CertificationPathStatus::STATUSES_IN_SUBMISSION}
      end
      if user.certifier?
        can [:edit_status, :update_status], CertificationPath, certification_path_status: {id: CertificationPathStatus::STATUSES_AT_CERTIFIER_SIDE}, project: project_with_user_as_certifier_manager
        can [:edit_certifier_team_responsibility, :allocate_certifier_team_responsibility], CertificationPath, project: project_with_user_as_certifier_manager, certification_path_status: {id: CertificationPathStatus::STATUSES_IN_VERIFICATION}
      end

      # SchemeMix controller
      can :read, SchemeMix, certification_path: {project: project_with_user_assigned, certification_path_status: {id: CertificationPathStatus::STATUSES_ACTIVATED}}
      can :update, SchemeMix, certification_path: {project: project_with_user_as_project_manager, certification_path_status: {id: CertificationPathStatus::ACTIVATING}, development_type: ['mixed_use', CertificationPath.development_types[:mixed_use], 'mixed_development', CertificationPath.development_types[:mixed_development], 'mixed_development_in_stages', CertificationPath.development_types[:mixed_development_in_stages]]}

      # SchemeMixCriterion controller
      can :read, SchemeMixCriterion, scheme_mix: {certification_path: {project: project_with_user_assigned, certification_path_status: {id: CertificationPathStatus::STATUSES_ACTIVATED}}}
      can :list, SchemeMixCriterion, scheme_mix: {certification_path: {project: project_with_user_assigned, certification_path_status: {id: CertificationPathStatus::STATUSES_ACTIVATED}}}
      if user.assessor?
        can [:edit_status, :update_status], SchemeMixCriterion, main_scheme_mix_criterion: nil, status: scheme_mix_criterion_status_submitting, scheme_mix: {certification_path: {certification_path_status: {id: CertificationPathStatus::STATUSES_IN_SUBMISSION}, project: project_with_user_as_project_manager}}
        # allows a submitted state, to be reset
        can [:edit_status, :update_status], SchemeMixCriterion, main_scheme_mix_criterion: nil, status: scheme_mix_criterion_status_submitted, scheme_mix: {certification_path: {certification_path_status: {id: CertificationPathStatus::STATUSES_IN_SUBMISSION}, project: project_with_user_as_project_manager}}
        # Managers can update scores depending on the status
        can :update_targeted_score, SchemeMixCriterion, main_scheme_mix_criterion: nil, status: scheme_mix_criterion_status_submitting, scheme_mix: {certification_path: {project: project_with_user_as_project_manager}}
        can :update_submitted_score, SchemeMixCriterion, main_scheme_mix_criterion: nil, status: scheme_mix_criterion_status_submitting, scheme_mix: {certification_path: {project: project_with_user_as_project_manager}}
        can :update_submitted_score, SchemeMixCriterion, main_scheme_mix_criterion: nil, status: scheme_mix_criterion_status_submitting, requirement_data: {user_id: user.id}, scheme_mix: {certification_path: {project: project_with_user_as_assessor}}
        can :request_review, SchemeMixCriterion, main_scheme_mix_criterion: nil, status: ['submitting', SchemeMixCriterion.statuses[:submitting]], scheme_mix: {certification_path: {certification_path_status: {id: CertificationPathStatus::SUBMITTING}, project: project_with_user_as_project_manager, pcr_track: true}}
      end
      if user.certifier?
        # allows a submitted state, to be reset
        can [:edit_status, :update_status], SchemeMixCriterion, main_scheme_mix_criterion: nil, status: scheme_mix_criterion_status_verifying, scheme_mix: {certification_path: {certification_path_status: {id: CertificationPathStatus::STATUSES_IN_VERIFICATION}, project: project_with_user_as_certifier_manager}}
        can [:edit_status, :update_status], SchemeMixCriterion, main_scheme_mix_criterion: nil, status: scheme_mix_criterion_status_verifying, certifier_id: user.id, scheme_mix: {certification_path: {certification_path_status: {id: CertificationPathStatus::STATUSES_IN_VERIFICATION}, project: project_with_user_as_certifier}}
        # Managers can update scores depending on the status
        can :update_achieved_score, SchemeMixCriterion, main_scheme_mix_criterion: nil, status: scheme_mix_criterion_status_verifying, scheme_mix: {certification_path: {project: project_with_user_as_certifier_manager}}
        can :update_achieved_score, SchemeMixCriterion, main_scheme_mix_criterion: nil, status: scheme_mix_criterion_status_verifying, certifier_id: user.id, scheme_mix: {certification_path: {project: project_with_user_as_certifier}}
        can :assign_certifier, SchemeMixCriterion, main_scheme_mix_criterion: nil, status: scheme_mix_criterion_status_verifying, scheme_mix: {certification_path: {project: project_with_user_as_certifier_manager}}
        can [:provide_review_comment, :add_review_comment], SchemeMixCriterion, main_scheme_mix_criterion: nil, in_review: true, scheme_mix: {certification_path: {project: project_with_user_as_certifier_manager}}
      end

      # RequirementDatum controller
      can :read, RequirementDatum, scheme_mix_criteria: {scheme_mix: {certification_path: {project: project_with_user_assigned, certification_path_status: {id: CertificationPathStatus::STATUSES_ACTIVATED}}}}
      if user.assessor?
        can :update, RequirementDatum, scheme_mix_criteria: {status: scheme_mix_criterion_status_submitting, scheme_mix: {certification_path: {project: project_with_user_as_project_manager}}}
        can :update_status, RequirementDatum, user_id: user.id, scheme_mix_criteria: {status: scheme_mix_criterion_status_submitting, scheme_mix: {certification_path: {project: project_with_user_as_assessor}}}
        can :refuse, RequirementDatum, user_id: user.id, scheme_mix_criteria: {status: scheme_mix_criterion_status_submitting, scheme_mix: {certification_path: {project: project_with_user_as_assessor}}}
      end

      # Document controller
      can :read, Document, scheme_mix_criteria_documents: { scheme_mix_criterion: {scheme_mix: {certification_path: {project: project_with_user_assigned}}}}
      if user.assessor?
        can :create, Document, scheme_mix_criteria_documents: { scheme_mix_criterion: {main_scheme_mix_criterion: nil, status: scheme_mix_criterion_status_submitting, scheme_mix: {certification_path: {project: project_with_user_as_assessor}}}}
      end

      # SchemeMixCriteriaDocument controller
      if user.assessor?
        can :read, SchemeMixCriteriaDocument, scheme_mix_criterion: {scheme_mix: {certification_path: {project: project_with_user_as_assessor}}}
        can [:update_status, :edit_status], SchemeMixCriteriaDocument, scheme_mix_criterion: {status: scheme_mix_criterion_status_submitting, scheme_mix: {certification_path: {project: project_with_user_as_project_manager}}}
        can [:create_link, :new_link], SchemeMixCriteriaDocument, scheme_mix_criterion: {status: scheme_mix_criterion_status_submitting, scheme_mix: {certification_path: {project: project_with_user_as_assessor}}}
      end
      if user.certifier?
        can :read, SchemeMixCriteriaDocument, status: document_approved, scheme_mix_criterion: {scheme_mix: {certification_path: {project: project_with_user_as_certifier}}}
        can :read, SchemeMixCriteriaDocument, scheme_mix_criterion: {in_review: true, scheme_mix: {certification_path: {project: project_with_user_as_certifier}}}
      end

      # AuditLog controller
      can :index, AuditLog, project: project_with_user_assigned
      can :auditable_index, AuditLog, project: project_with_user_assigned
      can :auditable_index_comments, AuditLog, project: project_with_user_assigned
      can :auditable_create, AuditLog #TODO:, project: project_with_user_assigned

      # Tasks controller
      can :read, Task
      can :count, Task

      # Tools controller
      can :manage, :tool

      # User controller
      can [:list_notifications,:update_notifications], User, id: user.id

    elsif user.gord_admin? || user.gord_manager? || user.gord_top_manager?
      can :read, :all
      # Project
      can [:download_location_plan, :download_site_plan, :download_design_brief, :download_project_narrative], Project
      can :show_tools, Project
      if user.gord_admin?
        can :update, Project
        can :delete, Project
      end
      # Project Users
      can :available, ProjectsUser
      # can :list_users_sharing_projects, ProjectsUser
      # can :list_projects, ProjectsUser
      if user.gord_admin?
        can :crud, ProjectsUser, role: project_user_assessor_roles
        can :crud, ProjectsUser, role: project_user_certifier_roles
        can :crud, ProjectsUser, role: project_user_enterprise_client_roles
        # can make another project_manager the project owner
        can :make_owner, ProjectsUser do |projects_user|
          projects_user.project_manager?
        end
        # The project_owner details can't be changed, first make another project_manager the owner
        cannot [:create, :update, :destroy, :make_owner], ProjectsUser do |projects_user|
          projects_user.project.owner_id == projects_user.user_id
        end
        # You can't add yourself
        cannot :create, ProjectsUser, user_id: user.id
      end
      # Certification Path
      can :list, CertificationPath
      can [:download_certificate, :download_certificate_coverletter, :download_scores_report], CertificationPath
      can :download_archive, CertificationPath
      if user.gord_admin?
        can [:edit_main_scheme_mix, :update_main_scheme_mix], CertificationPath, certification_path_status: {id: CertificationPathStatus::ACTIVATING}, development_type: ['mixed_use', CertificationPath.development_types[:mixed_use], 'mixed_development', CertificationPath.development_types[:mixed_development], 'mixed_development_in_stages', CertificationPath.development_types[:mixed_development_in_stages]]
        can [:edit_status, :update_status], CertificationPath, certification_path_status: {id: CertificationPathStatus::STATUSES_AT_ADMIN_SIDE}
        can [:edit_status, :update_status], CertificationPath, certification_path_status: {id: CertificationPathStatus::STATUSES_AT_ASSESSOR_SIDE}
        can [:edit_status, :update_status], CertificationPath, certification_path_status: {id: CertificationPathStatus::STATUSES_AT_CERTIFIER_SIDE}
        can [:edit_max_review_count, :update_max_review_count], CertificationPath
      elsif user.gord_top_manager?
        can [:edit_status, :update_status], CertificationPath, certification_path_status: {id: CertificationPathStatus::APPROVING_BY_TOP_MANAGEMENT}
      elsif user.gord_manager?
        can [:edit_status, :update_status], CertificationPath, certification_path_status: {id: CertificationPathStatus::APPROVING_BY_MANAGEMENT}
      end
      # SchemeMix
      cannot :read, SchemeMix, certification_path: {certification_path_status: {id: CertificationPathStatus::ACTIVATING}}
      can :update, SchemeMix, certification_path: {certification_path_status: {id: CertificationPathStatus::ACTIVATING}, development_type: ['mixed_use', CertificationPath.development_types[:mixed_use], 'mixed_development', CertificationPath.development_types[:mixed_development], 'mixed_development_in_stages', CertificationPath.development_types[:mixed_development_in_stages]]}
      # SchemeMixCriterion
      cannot :read, SchemeMixCriterion, scheme_mix: {certification_path: {certification_path_status: {id: CertificationPathStatus::ACTIVATING}}}
      cannot :list, SchemeMixCriterion, scheme_mix: {certification_path: {certification_path_status: {id: CertificationPathStatus::ACTIVATING}}}
      # RequirementDatum
      cannot :read, RequirementDatum, scheme_mix_criteria: {scheme_mix: {certification_path: {certification_path_status: {id: CertificationPathStatus::ACTIVATING}}}}
      # SchemeCriterionText
      if user.gord_admin?
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
      if user.gord_admin?
        can :create, User, role: user_role_assessor | user_role_certifier | user_role_enterprise_client| user_role_gord_admin
        can :update, User.unassigned, role: user_role_assessor | user_role_certifier | user_role_enterprise_client| user_role_gord_admin
      end

      # # Admins opt-out for specific abilities
      # cannot :apply_for_pcr, CertificationPath, pcr_track: true
      # cannot :apply_for_pcr, CertificationPath, certificate: {certificate_type: ['construction_type', Certificate.certificate_types[:construction_type], 'operations_type', Certificate.certificate_types[:operations_type]]}
      # cannot [:edit_status, :update_status], CertificationPath, certification_path_status: {id: CertificationPathStatus::STATUSES_AT_ASSESSOR_SIDE }
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
