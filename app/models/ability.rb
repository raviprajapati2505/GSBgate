class Ability
  include CanCan::Ability

  def initialize(user)
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/ryanb/cancan/wiki/Defining-Abilities

    user ||= User.new # guest user (not logged in)

    if user.system_admin?
      can :manage, :all
    elsif user.user?
      # User controller
      can :new_member, User, projects: {owner_id: user.id}
      can :new_member, User, projects: {project_authorizations: {user_id: user.id, role: ['project_manager', ProjectAuthorization.roles[:project_manager]]}}
      can :new_member, User, projects: {project_authorizations: {user_id: user.id, role: ['certifier_manager', ProjectAuthorization.roles[:certifier_manager]]}}
      can :index_tasks, User, projects: {owner_id: user.id}
      can :index_tasks, User, projects: {project_authorizations: {user_id: user.id, role: ['project_manager', ProjectAuthorization.roles[:project_manager]]}}
      can :index_tasks, User, projects: {project_authorizations: {user_id: user.id, role: ['certifier_manager', ProjectAuthorization.roles[:certifier_manager]]}}
      can :index_tasks, User, projects: {project_authorizations: {user_id: user.id, role: ['enterprise_account', ProjectAuthorization.roles[:enterprise_account]]}}
      # Project controller
      can :manage, Project, owner_id: user.id
      # Waiting for https://github.com/CanCanCommunity/cancancan/pull/196
      can :manage, Project, project_authorizations: {user_id: user.id, role: ['project_manager', ProjectAuthorization.roles[:project_manager]]}
      can :read, Project, project_authorizations: {user_id: user.id}
      # ProjectAuthorization controller
      can :manage, ProjectAuthorization, project: {owner_id: user.id}
      can :manage, ProjectAuthorization, project: {project_authorizations: {user_id: user.id, role: ['project_manager', ProjectAuthorization.roles[:project_manager]]}}
      can :manage, ProjectAuthorization, project: {project_authorizations: {user_id: user.id, role: ['certifier_manager', ProjectAuthorization.roles[:certifier_manager]]}}
      can :read, ProjectAuthorization, project: {project_authorizations: {user_id: user.id, role: ['enterprise_account', ProjectAuthorization.roles[:enterprise_account]]}}
      can :create, ProjectAuthorization
      # CertificationPath controller
      can :manage, CertificationPath, project: {owner_id: user.id}
      can :manage, CertificationPath, project: {project_authorizations: {user_id: user.id, role: ['project_manager', ProjectAuthorization.roles[:project_manager]]}}
      can :read, CertificationPath, project: {project_authorizations: {user_id: user.id, role: ['enterprise_account', ProjectAuthorization.roles[:enterprise_account]]}}
      # can :read, CertificationPath, scheme_mixes: {scheme_mix_criteria: {requirement_data: {user_id: user.id}}}
      # can :read, CertificationPath, scheme_mixes: {scheme_mix_criteria: {certifier_id: user.id}}
      can :read, CertificationPath, project: {project_authorizations: {user_id: user.id}}
      can :create, CertificationPath
      # SchemeMix controller
      can :manage, SchemeMix, certification_path: {project: {owner_id: user.id}}
      can :manage, SchemeMix, certification_path: {project: {project_authorizations: {user_id: user.id, role:  ['project_manager', ProjectAuthorization.roles[:project_manager]]}}}
      can :read, SchemeMix, certification_path: {project: {project_authorizations: {user_id: user.id, role:  ['enterprise_account', ProjectAuthorization.roles[:enterprise_account]]}}}
      # can :read, SchemeMix, scheme_mix_criteria: {requirement_data: {user_id: user.id}}
      # can :read, SchemeMix, scheme_mix_criteria: {certifier_id: user.id}
      can :read, SchemeMix, certification_path: {project: {project_authorizations: {user_id: user.id}}}
      # SchemeMixCriterion controller
      can :manage, SchemeMixCriterion, scheme_mix: {certification_path: {project: {owner_id: user.id}}}
      can :manage, SchemeMixCriterion, scheme_mix: {certification_path: {project: {project_authorizations: {user_id: user.id, role:  ['project_manager', ProjectAuthorization.roles[:project_manager]]}}}}
      can :read, SchemeMixCriterion, scheme_mix: {certification_path: {project: {project_authorizations: {user_id: user.id}}}}
      can :edit, SchemeMixCriterion, scheme_mix: {certification_path: {project: {project_authorizations: {user_id: user.id}}}}
      can :update, SchemeMixCriterion, requirement_data: {user_id: user.id}
      can :update, SchemeMixCriterion, certifier_id: user.id
      can :update, SchemeMixCriterion, scheme_mix: {certification_path: {project: {project_authorizations: {user_id: user.id, role: ['certifier_manager', ProjectAuthorization.roles[:certifier_manager]]}}}}
      can :assign_certifier, SchemeMixCriterion, scheme_mix: {certification_path: {project: {project_authorizations: {user_id: user.id, role: ['certifier_manager', ProjectAuthorization.roles[:certifier_manager]]}}}}
      # RequirementDatum controller
      can :manage, RequirementDatum, scheme_mix_criteria: {scheme_mix: {certification_path: {project: {owner_id: user.id}}}}
      can :manage, RequirementDatum, scheme_mix_criteria: {scheme_mix: {certification_path: {project: {project_authorizations: {user_id: user.id, role: ['project_manager', ProjectAuthorization.roles[:project_manager]]}}}}}
      can :update, RequirementDatum, user_id: user.id
      # Criteria status log
      can :read, SchemeMixCriterionLog, scheme_mix_criterion: {scheme_mix: {certification_path: {project: {owner_id: user.id}}}}
      can :read, SchemeMixCriterionLog, scheme_mix_criterion: {scheme_mix: {certification_path: {project: {project_authorizations: {user_id: user.id}}}}}
      # Document controller
      can :manage, Document, scheme_mix_criteria: {scheme_mix: {certification_path: {project: {owner_id: user.id}}}}
      can :manage, Document, scheme_mix_criteria: {scheme_mix: {certification_path: {project: {project_authorizations: {user_id: user.id, role: ['project_manager', ProjectAuthorization.roles[:project_manager]]}}}}}
      can :manage, Document, scheme_mix_criteria: {scheme_mix: {certification_path: {project: {project_authorizations: {user_id: user.id, role: ['project_team_member', ProjectAuthorization.roles[:project_team_member]]}}}}}
      can :read, Document, scheme_mix_criteria: {scheme_mix: {certification_path: {project: {project_authorizations: {user_id: user.id}}}}}
      # SchemeMixCriteriaDocument controller
      can :manage, SchemeMixCriteriaDocument, scheme_mix_criterion: {scheme_mix: {certification_path: {project: {owner_id: user.id}}}}
      can :manage, SchemeMixCriteriaDocument, scheme_mix_criterion: {scheme_mix: {certification_path: {project: {project_authorizations: {user_id: user.id, role: ['project_manager', ProjectAuthorization.roles[:project_manager]]}}}}}
      can :create, SchemeMixCriteriaDocument, scheme_mix_criterion: {scheme_mix: {certification_path: {project: {project_authorizations: {user_id: user.id, role: ['project_team_member', ProjectAuthorization.roles[:project_team_member]]}}}}}
      can :destroy, SchemeMixCriteriaDocument, scheme_mix_criterion: {scheme_mix: {certification_path: {project: {project_authorizations: {user_id: user.id, role: ['project_team_member', ProjectAuthorization.roles[:project_team_member]]}}}}}
      can :show, SchemeMixCriteriaDocument, scheme_mix_criterion: {scheme_mix: {certification_path: {project: {project_authorizations: {user_id: user.id}}}}}
      # SchemeMixCriteriaDocumentComment controller
      can :create, SchemeMixCriteriaDocumentComment
      # Notification controller
      can :manage, Notification
    else
      cannot :manage, :all
    end
  end
end
