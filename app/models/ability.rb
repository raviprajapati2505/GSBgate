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
      can :manage, Project, owner_id: user.id
      # Waiting for https://github.com/CanCanCommunity/cancancan/pull/196
      can :manage, Project, projects_users: {user_id: user.id, role: ['project_manager', ProjectsUser.roles[:project_manager]]}
      can :read, Project, projects_users: {user_id: user.id}
      # ProjectsUsers controller
      can :manage, ProjectsUser, role: ['project_team_member', ProjectsUser.roles[:project_team_member], 'project_manager', ProjectsUser.roles[:project_manager], 'enterprise_account', ProjectsUser.roles[:enterprise_account]], project: {projects_users: {user_id: user.id, role: ['project_manager', ProjectsUser.roles[:project_manager]]}}
      can :manage, ProjectsUser, role: ['certifier', ProjectsUser.roles[:certifier], 'certifier_manager', ProjectsUser.roles[:certifier_manager]], project: {projects_users: {user_id: user.id, role: ['certifier_manager', ProjectsUser.roles[:certifier_manager]]}}
      can :read, ProjectsUser, project: {projects_users: {user_id: user.id}}
      can :create, ProjectsUser, project: {owner_id: user.id}
      cannot :destroy, ProjectsUser do |projects_user|
        projects_user.project.owner_id == projects_user.user_id
      end
      # CertificationPath controller
      can :manage, CertificationPath, project: {projects_users: {user_id: user.id, role: ['project_manager', ProjectsUser.roles[:project_manager]]}}
      can :update_pcr, CertificationPath, project: {projects_users: {user_id: user.id, role: ['certifier_manager', ProjectsUser.roles[:certifier_manager]]}}
      can :update_status, CertificationPath, project: {projects_users: {user_id: user.id, role: ['project_manager', ProjectsUser.roles[:project_manager]]}}
      can :update_status, CertificationPath, project: {projects_users: {user_id: user.id, role: ['certifier_manager', ProjectsUser.roles[:certifier_manager]]}}
      can :read, CertificationPath, project: {projects_users: {user_id: user.id}}
      can :apply, CertificationPath, project: {projects_users: {user_id: user.id, role: ['project_manager', ProjectsUser.roles[:project_manager]]}}
      can :list, CertificationPath, project: {projects_users: {user_id: user.id}}
      # SchemeMix controller
      can :read, SchemeMix, certification_path: {project: {projects_users: {user_id: user.id, role: ['project_manager', ProjectsUser.roles[:project_manager]]}}}
      can :read, SchemeMix, certification_path: {project: {projects_users: {user_id: user.id}}}
      can :allocate_project_team_responsibility, SchemeMix, certification_path: {project: {projects_users: {user_id: user.id, role: ['project_manager', ProjectsUser.roles[:project_manager]]}}}
      can :allocate_certifier_team_responsibility, SchemeMix, certification_path: {project: {projects_users: {user_id: user.id, role: ['certifier_manager', ProjectsUser.roles[:certifier_manager]]}}}
      # SchemeMixCriterion controller
      can :manage, SchemeMixCriterion, scheme_mix: {certification_path: {project: {projects_users: {user_id: user.id, role:  ['project_manager', ProjectsUser.roles[:project_manager]]}}}}
      can :read, SchemeMixCriterion, scheme_mix: {certification_path: {project: {projects_users: {user_id: user.id}}}}
      can :edit, SchemeMixCriterion, scheme_mix: {certification_path: {project: {projects_users: {user_id: user.id}}}}
      can :update, SchemeMixCriterion, requirement_data: {user_id: user.id}
      can :update, SchemeMixCriterion, certifier_id: user.id
      can :update, SchemeMixCriterion, scheme_mix: {certification_path: {project: {projects_users: {user_id: user.id, role: ['certifier_manager', ProjectsUser.roles[:certifier_manager]]}}}}
      can :assign_certifier, SchemeMixCriterion, scheme_mix: {certification_path: {project: {projects_users: {user_id: user.id, role: ['certifier_manager', ProjectsUser.roles[:certifier_manager]]}}}}
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
      can :create, SchemeMixCriteriaDocument, scheme_mix_criterion: {scheme_mix: {certification_path: {project: {projects_users: {user_id: user.id, role: ['project_team_member', ProjectsUser.roles[:project_team_member]]}}}}}
      can :destroy, SchemeMixCriteriaDocument, scheme_mix_criterion: {scheme_mix: {certification_path: {project: {projects_users: {user_id: user.id, role: ['project_team_member', ProjectsUser.roles[:project_team_member]]}}}}}
      can :read, SchemeMixCriteriaDocument, scheme_mix_criterion: {scheme_mix: {certification_path: {project: {projects_users: {user_id: user.id}}}}}
      # AuditLog controller
      can :read, AuditLog
      can :auditable_index, AuditLog
      can :auditable_create, AuditLog
      # Tasks controller
      can :read, Task
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
