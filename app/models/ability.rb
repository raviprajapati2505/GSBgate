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

    # Note: we use the following basic rule:
    #   Admins can do everything, unless they explicitly OPT-OUT of specific abilities
    #   Users can do nothing, unless they explicitly OPT-IN to specific abilities

    user ||= User.new # guest user (not logged in)

    alias_action :create, :read, :update, :destroy, :to => :crud

    # Some convenience variables to work with enums in conditions
    #   Note: there is a known issue, that complicates working with enums
    #     https://github.com/CanCanCommunity/cancancan/pull/196
    #   Roles
    role_project_manager = ['project_manager', ProjectsUser.roles[:project_manager]]
    role_project_team_member = ['project_team_member', ProjectsUser.roles[:project_team_member]]
    role_certifier_manager = ['certifier_manager', ProjectsUser.roles[:certifier_manager]]
    role_certifier = ['certifier', ProjectsUser.roles[:certifier]]
    assessor_roles = role_project_manager | role_project_team_member
    certifier_roles = role_certifier_manager | role_certifier
    #role_enterprise_account = ['enterprise_account', ProjectsUser.roles[:enterprise_account]]
    #   SchemeMixCriterion.statuses
    scheme_mix_criterion_status_submitting = ['submitting', SchemeMixCriterion.statuses[:submitting], 'submitting_after_appeal', SchemeMixCriterion.statuses[:submitting_after_appeal]]
    scheme_mix_criterion_status_submitted = ['submitted', SchemeMixCriterion.statuses[:submitted], 'submitted_after_appeal', SchemeMixCriterion.statuses[:submitted_after_appeal]]
    scheme_mix_criterion_status_verifying = ['verifying', SchemeMixCriterion.statuses[:verifying], 'verifying_after_appeal', SchemeMixCriterion.statuses[:verifying_after_appeal]]
    #scheme_mix_criterion_status_verified = ['target_achieved', SchemeMixCriterion.statuses[:target_achieved], 'target_not_achieved', SchemeMixCriterion.statuses[:target_not_achieved], 'target_achieved_after_appeal', SchemeMixCriterion.statuses[:target_achieved_after_appeal], 'target_not_achieved_after_appeal', SchemeMixCriterion.statuses[:target_not_achieved_after_appeal]]
    #   SchemeMixCriteriaDocument.statuses
    document_approved = ['approved', SchemeMixCriteriaDocument.statuses[:approved]]

    # Convenience conditions, to use within abilities
    project_with_user_assigned = {projects_users: {user_id: user.id}}
    project_with_user_as_project_manager = {projects_users: {user_id: user.id, role: role_project_manager}}
    project_with_user_as_assessor = {projects_users: {user_id: user.id, role: assessor_roles}}
    project_with_user_as_certifier_manager = {projects_users: {user_id: user.id, role: role_certifier_manager}}
    project_with_user_as_certifier = {projects_users: {user_id: user.id, role: certifier_roles}}


    if user.system_admin?
      can :manage, :all
      # Admins opt-out for specific abilities
      cannot [:edit_status, :update_status], CertificationPath, certification_path_status: {id: CertificationPathStatus::STATUSES_AT_ASSESSOR_SIDE }
      cannot [:edit_status, :update_status], CertificationPath, certification_path_status: {id: CertificationPathStatus::STATUSES_AT_MANAGEMENT_SIDE}
      cannot [:edit_status, :update_status], CertificationPath, certification_path_status: {id: CertificationPathStatus::STATUSES_AT_END}
      cannot [:edit_project_team_responsibility, :allocate_project_team_responsibility], CertificationPath do |certification_path| !CertificationPathStatus::STATUSES_IN_SUBMISSION.include?(certification_path.certification_path_status_id) end
      cannot [:edit_certifier_team_responsibility, :allocate_certifier_team_responsibility], CertificationPath do |certification_path| !CertificationPathStatus::STATUSES_IN_VERIFICATION.include?(certification_path.certification_path_status_id) end
      cannot :update_achieved_score, SchemeMixCriterion do |scheme_mix_criterion| ![SchemeMixCriterion.statuses[:submitting], SchemeMixCriterion.statuses[:submitting_after_appeal]].include?(scheme_mix_criterion.status) end
      cannot :update_achieved_score, SchemeMixCriterion do |scheme_mix_criterion| ![SchemeMixCriterion.statuses[:verifying], SchemeMixCriterion.statuses[:verifying_after_appeal]].include?(scheme_mix_criterion.status) end
      cannot :refuse, RequirementDatum do |requirement_datum| requirement_datum.user_id != user.id end
    elsif user.user?
      # User controller
      #   Note: only admins can manage user accounts !
      can [:list_notifications,:update_notifications], User, id: user.id

      # Project controller
      can :read, Project, projects_users: {user_id: user.id}
      can :create, Project, owner_id: user.id
      can :update, Project, projects_users: {user_id: user.id, role: role_project_manager}
      can [:download_location_plan, :download_site_plan, :download_design_brief, :download_project_narrative], Project, projects_users: {user_id: user.id}
      can :show_tools, Project, projects_users: {user_id: user.id}

      # ProjectsUsers controller
      can :read, ProjectsUser, role: assessor_roles, project: project_with_user_as_assessor
      can :read, ProjectsUser, role: certifier_roles, project: project_with_user_as_certifier
      can :crud, ProjectsUser, role: assessor_roles, project: project_with_user_as_project_manager
      can :crud, ProjectsUser, role: certifier_roles, project: project_with_user_as_certifier_manager
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
      can :apply, CertificationPath, project: project_with_user_as_project_manager
      can :apply_for_pcr, CertificationPath, pcr_track: false, project: project_with_user_as_project_manager
      can [:edit_status, :update_status], CertificationPath, certification_path_status: {id: CertificationPathStatus::STATUSES_AT_ASSESSOR_SIDE}, project: project_with_user_as_project_manager
      can [:edit_status, :update_status], CertificationPath, certification_path_status: {id: CertificationPathStatus::STATUSES_AT_CERTIFIER_SIDE}, project: project_with_user_as_certifier_manager

      can [:edit_project_team_responsibility, :allocate_project_team_responsibility], CertificationPath, project: project_with_user_as_project_manager, certification_path_status: {id: CertificationPathStatus::STATUSES_IN_SUBMISSION}
      can [:edit_certifier_team_responsibility, :allocate_certifier_team_responsibility], CertificationPath, project: project_with_user_as_certifier_manager, certification_path_status: {id: CertificationPathStatus::STATUSES_IN_VERIFICATION}
      can [:download_certificate, :download_certificate_coverletter, :download_scores_report], CertificationPath, project: project_with_user_assigned
      can :download_archive, CertificationPath, project: project_with_user_assigned

      # SchemeMix controller
      can :read, SchemeMix, certification_path: {project: project_with_user_assigned}

      # SchemeMixCriterion controller
      can :read, SchemeMixCriterion, scheme_mix: {certification_path: {project: project_with_user_assigned}}
      can :list, SchemeMixCriterion, scheme_mix: {certification_path: {project: project_with_user_assigned}}
      can [:edit_status, :update_status], SchemeMixCriterion, status: scheme_mix_criterion_status_submitting, scheme_mix: {certification_path: {certification_path_status: {id: CertificationPathStatus::STATUSES_IN_SUBMISSION}, project: project_with_user_as_project_manager}}
      # allows a submitted state, to be reset
      can [:edit_status, :update_status], SchemeMixCriterion, status: scheme_mix_criterion_status_submitted, scheme_mix: {certification_path: {certification_path_status: {id: CertificationPathStatus::STATUSES_IN_SUBMISSION}, project: project_with_user_as_project_manager}}
      can [:edit_status, :update_status], SchemeMixCriterion, status: scheme_mix_criterion_status_verifying, scheme_mix: {certification_path: {certification_path_status: {id: CertificationPathStatus::STATUSES_IN_VERIFICATION}, project: project_with_user_as_certifier_manager}}
      can [:edit_status, :update_status], SchemeMixCriterion, status: scheme_mix_criterion_status_verifying, certifier_id: user.id, scheme_mix: {certification_path: {certification_path_status: {id: CertificationPathStatus::STATUSES_IN_VERIFICATION}, project: project_with_user_as_certifier}}
      # Managers can update scores depending on the status
      can :update_targeted_score, SchemeMixCriterion, status: scheme_mix_criterion_status_submitting, scheme_mix: {certification_path: {project: project_with_user_as_project_manager}}
      can :update_submitted_score, SchemeMixCriterion, status: scheme_mix_criterion_status_submitting, scheme_mix: {certification_path: {project: project_with_user_as_project_manager}}
      can :update_submitted_score, SchemeMixCriterion, status: scheme_mix_criterion_status_submitting, requirement_data: {user_id: user.id}, scheme_mix: {certification_path: {project: project_with_user_as_assessor}}
      can :update_achieved_score, SchemeMixCriterion, status: scheme_mix_criterion_status_verifying, scheme_mix: {certification_path: {project: project_with_user_as_certifier_manager}}
      can :update_achieved_score, SchemeMixCriterion, status: scheme_mix_criterion_status_verifying, certifier_id: user.id, scheme_mix: {certification_path: {project: project_with_user_as_certifier}}
      can :assign_certifier, SchemeMixCriterion, status: scheme_mix_criterion_status_verifying, scheme_mix: {certification_path: {project: project_with_user_as_certifier_manager}}

      # RequirementDatum controller
      can :read, RequirementDatum, scheme_mix_criteria: {scheme_mix: {certification_path: {project: project_with_user_assigned}}}
      can :update, RequirementDatum, scheme_mix_criteria: {status: scheme_mix_criterion_status_submitting, scheme_mix: {certification_path: {project: project_with_user_as_project_manager}}}
      can :update_status, RequirementDatum, user_id: user.id, scheme_mix_criteria: {status: scheme_mix_criterion_status_submitting, scheme_mix: {certification_path: {project: project_with_user_as_assessor}}}
      can :refuse, RequirementDatum, user_id: user.id, scheme_mix_criteria: {status: scheme_mix_criterion_status_submitting, scheme_mix: {certification_path: {project: project_with_user_as_assessor}}}

      # Document controller
      can :read, Document, scheme_mix_criteria_documents: { scheme_mix_criterion: {scheme_mix: {certification_path: {project: project_with_user_assigned}}}}
      can :create, Document, scheme_mix_criteria_documents: { scheme_mix_criterion: {status: scheme_mix_criterion_status_submitting, scheme_mix: {certification_path: {project: project_with_user_as_assessor}}}}

      # SchemeMixCriteriaDocument controller
      can :read, SchemeMixCriteriaDocument, scheme_mix_criterion: {scheme_mix: {certification_path: {project: project_with_user_as_assessor}}}
      can :read, SchemeMixCriteriaDocument, status: document_approved, scheme_mix_criterion: {scheme_mix: {certification_path: {project: project_with_user_as_certifier}}}
      can :read, SchemeMixCriteriaDocument, scheme_mix_criterion: {scheme_mix: {certification_path: {project: project_with_user_as_certifier, certification_path_status: {id: CertificationPathStatus::SUBMITTING_PCR}}}}
      can [:update_status, :edit_status], SchemeMixCriteriaDocument, scheme_mix_criterion: {status: scheme_mix_criterion_status_submitting, scheme_mix: {certification_path: {project: project_with_user_as_project_manager}}}
      can [:create_link, :new_link], SchemeMixCriteriaDocument, scheme_mix_criterion: {status: scheme_mix_criterion_status_submitting, scheme_mix: {certification_path: {project: project_with_user_as_assessor}}}

      # AuditLog controller
      can :index, AuditLog, project: project_with_user_assigned
      can :auditable_index, AuditLog, project: project_with_user_assigned
      can :auditable_create, AuditLog, project: project_with_user_assigned

      # Tasks controller
      can :read, Task
      can :count, Task

    elsif user.gord_manager? || user.gord_top_manager?
      can :read, :all
      # Project
      can [:download_location_plan, :download_site_plan, :download_design_brief, :download_project_narrative], Project
      can :show_tools, Project
      # Certification Path
      can :list, CertificationPath
      can [:download_certificate, :download_certificate_coverletter, :download_scores_report], CertificationPath
      can :download_archive, CertificationPath
      # SchemeMixCriterion
      can :list, SchemeMixCriterion
      # Audit log
      can :index, AuditLog
      can :auditable_index, AuditLog
      # Task
      can :count, Task
      # User controller
      can [:list_notifications,:update_notifications], User, id: user.id

      if user.gord_top_manager?
        can [:edit_status, :update_status], CertificationPath, certification_path_status: {id: CertificationPathStatus::APPROVING_BY_TOP_MANAGEMENT}
      elsif user.gord_manager?
        can [:edit_status, :update_status], CertificationPath, certification_path_status: {id: CertificationPathStatus::APPROVING_BY_MANAGEMENT}
      end

    else
      cannot :manage, :all

    end
  end
end
