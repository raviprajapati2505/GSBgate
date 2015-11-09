class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here.
    #
    # The first argument to `can` is the action you are giving the user permission to do.
    # If you pass :manage it will apply to every action. Other common actions here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the objects.
    # For example, here the user can only update published articles.
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/ryanb/cancan/wiki/Defining-Abilities

    # Note: there is a known issue, that complicates working with enums
    # https://github.com/CanCanCommunity/cancancan/pull/196

    user ||= User.new # guest user (not logged in)

    if user.system_admin?
      can :manage, :all
    elsif user.user?

      # User controller
      can :show, User
      can :new_member, User, projects: {projects_users: {user_id: user.id, role: ['project_manager', ProjectsUser.roles[:project_manager]]}}
      can :new_member, User, projects: {projects_users: {user_id: user.id, role: ['certifier_manager', ProjectsUser.roles[:certifier_manager]]}}
      can :index_tasks, User, projects: {projects_users: {user_id: user.id}}

      # Project controller
      can :manage, Project, {owner_id: user.id}
      can :read, Project, projects_users: {user_id: user.id}
      can :manage, Project, projects_users: {user_id: user.id, role: ['project_manager', ProjectsUser.roles[:project_manager]]}
      can :download_location_plan, Project, projects_users: {user_id: user.id}
      can :download_site_plan, Project, projects_users: {user_id: user.id}
      can :download_design_brief, Project, projects_users: {user_id: user.id}
      can :download_project_narrative, Project, projects_users: {user_id: user.id}
      can :show_tools, Project, projects_users: {user_id: user.id}

      # ProjectsUsers controller
      can :read, ProjectsUser, role: ['project_team_member', ProjectsUser.roles[:project_team_member], 'project_manager', ProjectsUser.roles[:project_manager], 'enterprise_account', ProjectsUser.roles[:enterprise_account]], project: {projects_users: {user_id: user.id, role: ['project_team_member', ProjectsUser.roles[:project_team_member], 'project_manager', ProjectsUser.roles[:project_manager], 'enterprise_account', ProjectsUser.roles[:enterprise_account]]}}
      can :read, ProjectsUser, role: ['certifier', ProjectsUser.roles[:certifier], 'certifier_manager', ProjectsUser.roles[:certifier_manager]], project: {projects_users: {user_id: user.id, role: ['certifier', ProjectsUser.roles[:certifier], 'certifier_manager', ProjectsUser.roles[:certifier_manager]]}}
      can :create, ProjectsUser, project: {projects_users: {user_id: user.id, role: ['project_manager', ProjectsUser.roles[:project_manager], 'certifier_manager', ProjectsUser.roles[:certifier_manager]]}}
      can :manage, ProjectsUser, role: ['project_team_member', ProjectsUser.roles[:project_team_member], 'project_manager', ProjectsUser.roles[:project_manager], 'enterprise_account', ProjectsUser.roles[:enterprise_account]], project: {projects_users: {user_id: user.id, role: ['project_manager', ProjectsUser.roles[:project_manager]]}}
      can :manage, ProjectsUser, role: ['certifier', ProjectsUser.roles[:certifier], 'certifier_manager', ProjectsUser.roles[:certifier_manager]], project: {projects_users: {user_id: user.id, role: ['certifier_manager', ProjectsUser.roles[:certifier_manager]]}}
      cannot :create, ProjectsUser, user_id: user.id
      cannot [:update, :destroy, :make_owner], ProjectsUser do |projects_user|
        projects_user.project.owner_id == projects_user.user_id || projects_user.user_id == user.id
      end

      # CertificationPath controller
      can :apply, CertificationPath, project: {projects_users: {user_id: user.id, role: ['project_manager', ProjectsUser.roles[:project_manager]]}}
      can :read, CertificationPath, project: {projects_users: {user_id: user.id}}
      can :update_pcr, CertificationPath, project: {projects_users: {user_id: user.id, role: ['certifier_manager', ProjectsUser.roles[:certifier_manager]]}}
      can [:edit_status, :update_status], CertificationPath, project: {projects_users: {user_id: user.id, role: ['certifier_manager', ProjectsUser.roles[:certifier_manager], 'project_manager', ProjectsUser.roles[:project_manager]]}}
      can :list, CertificationPath, project: {projects_users: {user_id: user.id}}
      can :allocate_project_team_responsibility, CertificationPath, project: {projects_users: {user_id: user.id, role: ['project_manager', ProjectsUser.roles[:project_manager]]}}
      cannot :allocate_project_team_responsibility, CertificationPath, project: {projects_users: {user_id: user.id, role: ['certifier_manager', ProjectsUser.roles[:certifier_manager]]}}
      can :allocate_certifier_team_responsibility, CertificationPath, project: {projects_users: {user_id: user.id, role: ['certifier_manager', ProjectsUser.roles[:certifier_manager]]}}
      cannot :allocate_certifier_team_responsibility, CertificationPath, project: {projects_users: {user_id: user.id, role: ['project_manager', ProjectsUser.roles[:project_manager]]}}
      can :download_archive, CertificationPath, project: {projects_users: {user_id: user.id}}

      # SchemeMix controller
      can :read, SchemeMix, certification_path: {project: {projects_users: {user_id: user.id, role: ['project_manager', ProjectsUser.roles[:project_manager]]}}}
      can :read, SchemeMix, certification_path: {project: {projects_users: {user_id: user.id}}}

      # SchemeMixCriterion controller
      can :manage, SchemeMixCriterion, scheme_mix: {certification_path: {project: {projects_users: {user_id: user.id, role: ['certifier_manager', ProjectsUser.roles[:certifier_manager]]}}}}
      can :read, SchemeMixCriterion, scheme_mix: {certification_path: {project: {projects_users: {user_id: user.id}}}}
      can [:edit_status, :update_status], SchemeMixCriterion, scheme_mix: {certification_path: {project: {projects_users: {user_id: user.id, role: ['project_manager', ProjectsUser.roles[:project_manager]]}}}}
      can [:edit_status, :update_status], SchemeMixCriterion, certifier_id: user.id
      can :list, SchemeMixCriterion, scheme_mix: {certification_path: {project: {projects_users: {user_id: user.id}}}}
      can :update_scores, SchemeMixCriterion, scheme_mix: {certification_path: {project: {projects_users: {user_id: user.id, role: ['project_manager', ProjectsUser.roles[:project_manager]]}}}}
      can :update_scores, SchemeMixCriterion, requirement_data: {user_id: user.id}
      can :update_scores, SchemeMixCriterion, certifier_id: user.id

      # RequirementDatum controller
      can :manage, RequirementDatum, scheme_mix_criteria: {scheme_mix: {certification_path: {project: {projects_users: {user_id: user.id, role: ['project_manager', ProjectsUser.roles[:project_manager]]}}}}}
      can :read, RequirementDatum, scheme_mix_criteria: {scheme_mix: {certification_path: {project: {projects_users: {user_id: user.id}}}}}
      can :update, RequirementDatum, user_id: user.id
      can :refuse, RequirementDatum, user_id: user.id

      # Document controller
      can :manage, Document, scheme_mix_criteria: {scheme_mix: {certification_path: {project: {projects_users: {user_id: user.id, role: ['project_manager', ProjectsUser.roles[:project_manager]]}}}}}
      can :manage, Document, scheme_mix_criteria: {scheme_mix: {certification_path: {project: {projects_users: {user_id: user.id, role: ['project_team_member', ProjectsUser.roles[:project_team_member]]}}}}}
      can :read, Document, scheme_mix_criteria: {scheme_mix: {certification_path: {project: {projects_users: {user_id: user.id}}}}}

      # SchemeMixCriteriaDocument controller
      can :manage, SchemeMixCriteriaDocument, scheme_mix_criterion: {scheme_mix: {certification_path: {project: {projects_users: {user_id: user.id, role: ['project_manager', ProjectsUser.roles[:project_manager]]}}}}}
      can :new_link, SchemeMixCriteriaDocument, scheme_mix_criterion: {scheme_mix: {certification_path: {project: {projects_users: {user_id: user.id, role: ['project_team_member', ProjectsUser.roles[:project_team_member]]}}}}}
      can :create_link, SchemeMixCriteriaDocument, scheme_mix_criterion: {scheme_mix: {certification_path: {project: {projects_users: {user_id: user.id, role: ['project_team_member', ProjectsUser.roles[:project_team_member]]}}}}}
      can :read, SchemeMixCriteriaDocument, scheme_mix_criterion: {scheme_mix: {certification_path: {project: {projects_users: {user_id: user.id}}}}}

      # AuditLog controller
      can :read, AuditLog
      can :auditable_index, AuditLog, project: {projects_users: {user_id: user.id}}
      can :auditable_create, AuditLog

      # Tasks controller
      can :read, Task
      can :count, Task

    elsif user.gord_top_manager?
      # dr. Youssef
      can :manage, :all
    elsif user.gord_manager?
      # dr. Esam
      can :manage, :all
    else
      cannot :manage, :all
    end
  end
end
