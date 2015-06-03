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
    elsif user.assessor?
      can :manage, Project, owner_id: user.id
      can :manage, ProjectAuthorization, project: {owner_id: user.id}
      # can :new, ProjectAuthorization
      # can :create, ProjectAuthorization
      can :manage, CertificationPath, project: {owner_id: user.id}
      # can :new, CertificationPath
      # can :create, CertificationPath
      can :manage, SchemeMix, certification_path: {project: {owner_id: user.id}}

      can :read, Project, project_authorizations: {user_id: user.id}
      # Waiting for https://github.com/CanCanCommunity/cancancan/pull/196
      can :manage, Project, project_authorizations: {user_id: user.id, permission: ['manage', ProjectAuthorization.permissions[:manage]]}
      can :manage, ProjectAuthorization, project: {project_authorizations: {user_id: user.id, permission: ['manage', ProjectAuthorization.permissions[:manage]]}}
      if can? :manage, Project
        can :new, ProjectAuthorization
        can :create, ProjectAuthorization
      end
      can :manage, CertificationPath, project: {project_authorizations: {user_id: user.id, permission: ['manage', ProjectAuthorization.permissions[:manage]]}}
      if can? :manage, Project
        can :new, CertificationPath
        can :create, CertificationPath
      end
      can :manage, SchemeMix, certification_path: {project: {project_authorizations: {user_id: user.id, permission:  ['manage', ProjectAuthorization.permissions[:manage]]}}}

    elsif user.enterprise_licence?
      can :read, Project, client_id: user.id
      can :read, ProjectAuthorization, project: {client_id: user.id}
      can :read, CertificationPath, project: {client_id: user.id}

    else
      cannot :manage, :all
    end
  end
end
