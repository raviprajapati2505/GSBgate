class TaskService
  include Singleton

  def generate_tasks(user:, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []

    if user.system_admin?
      tasks += generate_system_admin_tasks(user: user,
                                           project_id: project_id,
                                           certification_path_id: certification_path_id,
                                           scheme_mix_criterion_id: scheme_mix_criterion_id)
    elsif user.gord_manager?
      tasks += generate_gord_mngr_tasks(user: user,
                                        project_id: project_id,
                                        certification_path_id: certification_path_id,
                                        scheme_mix_criterion_id: scheme_mix_criterion_id)
    elsif user.gord_top_manager?
      tasks += generate_gord_top_mngr_tasks(user: user,
                                            project_id: project_id,
                                            certification_path_id: certification_path_id,
                                            scheme_mix_criterion_id: scheme_mix_criterion_id)
    else
      tasks += generate_project_mngr_tasks(user: user,
                                           project_id: project_id,
                                           certification_path_id: certification_path_id,
                                           scheme_mix_criterion_id: scheme_mix_criterion_id)
      tasks += generate_project_member_tasks(user: user,
                                             project_id: project_id,
                                             certification_path_id: certification_path_id,
                                             scheme_mix_criterion_id: scheme_mix_criterion_id)
      tasks += generate_certifier_mngr_tasks(user: user,
                                             project_id: project_id,
                                             certification_path_id: certification_path_id,
                                             scheme_mix_criterion_id: scheme_mix_criterion_id)
      tasks += generate_certifier_member_tasks(user: user,
                                               project_id: project_id,
                                               certification_path_id: certification_path_id,
                                               scheme_mix_criterion_id: scheme_mix_criterion_id)
    end

    return tasks
  end

  def generate_system_admin_tasks(user:, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []
    tasks += generate_system_admin_tasks_1(user: user, project_id: project_id, certification_path_id: certification_path_id, scheme_mix_criterion_id: scheme_mix_criterion_id)
    tasks += generate_system_admin_tasks_2(user: user, project_id: project_id, certification_path_id: certification_path_id, scheme_mix_criterion_id: scheme_mix_criterion_id)
    tasks += generate_system_admin_tasks_11(user: user, project_id: project_id, certification_path_id: certification_path_id, scheme_mix_criterion_id: scheme_mix_criterion_id)
    return tasks
  end

  def generate_gord_top_mngr_tasks(user:, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []
    tasks += generate_gord_top_mngr_tasks_20(user: user, project_id: project_id, certification_path_id: certification_path_id, scheme_mix_criterion_id: scheme_mix_criterion_id)
    tasks += generate_gord_top_mngr_tasks_21(user: user, project_id: project_id, certification_path_id: certification_path_id, scheme_mix_criterion_id: scheme_mix_criterion_id)
    return tasks
  end

  def generate_gord_mngr_tasks(user:, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []
    tasks += generate_gord_mngr_tasks_19(user: user, project_id: project_id, certification_path_id: certification_path_id, scheme_mix_criterion_id: scheme_mix_criterion_id)
    return tasks
  end

  def generate_project_mngr_tasks(user:, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []
    tasks += generate_project_mngr_tasks_3(user: user, project_id: project_id, certification_path_id: certification_path_id, scheme_mix_criterion_id: scheme_mix_criterion_id)
    tasks += generate_project_mngr_tasks_5(user: user, project_id: project_id, certification_path_id: certification_path_id, scheme_mix_criterion_id: scheme_mix_criterion_id)
    tasks += generate_project_mngr_tasks_6(user: user, project_id: project_id, certification_path_id: certification_path_id, scheme_mix_criterion_id: scheme_mix_criterion_id)
    tasks += generate_project_mngr_tasks_10(user: user, project_id: project_id, certification_path_id: certification_path_id, scheme_mix_criterion_id: scheme_mix_criterion_id)
    tasks += generate_project_mngr_tasks_14(user: user, project_id: project_id, certification_path_id: certification_path_id, scheme_mix_criterion_id: scheme_mix_criterion_id)
    tasks += generate_project_mngr_tasks_17(user: user, project_id: project_id, certification_path_id: certification_path_id, scheme_mix_criterion_id: scheme_mix_criterion_id)
    tasks += generate_project_mngr_tasks_18(user: user, project_id: project_id, certification_path_id: certification_path_id, scheme_mix_criterion_id: scheme_mix_criterion_id)
    tasks += generate_project_mngr_tasks_22(user: user, project_id: project_id, certification_path_id: certification_path_id, scheme_mix_criterion_id: scheme_mix_criterion_id)
    return tasks
  end

  def generate_project_member_tasks(user:, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []
    tasks += generate_project_member_tasks_4(user: user, project_id: project_id, certification_path_id: certification_path_id, scheme_mix_criterion_id: scheme_mix_criterion_id)
    return tasks
  end

  def generate_certifier_mngr_tasks(user:, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []
    tasks += generate_certifier_mngr_tasks_7(user: user, project_id: project_id, certification_path_id: certification_path_id, scheme_mix_criterion_id: scheme_mix_criterion_id)
    tasks += generate_certifier_mngr_tasks_9(user: user, project_id: project_id, certification_path_id: certification_path_id, scheme_mix_criterion_id: scheme_mix_criterion_id)
    tasks += generate_certifier_mngr_tasks_13(user: user, project_id: project_id, certification_path_id: certification_path_id, scheme_mix_criterion_id: scheme_mix_criterion_id)
    tasks += generate_certifier_mngr_tasks_16(user: user, project_id: project_id, certification_path_id: certification_path_id, scheme_mix_criterion_id: scheme_mix_criterion_id)
    return tasks
  end

  def generate_certifier_member_tasks(user:, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []
    tasks += generate_certifier_member_tasks_8(user: user, project_id: project_id, certification_path_id: certification_path_id, scheme_mix_criterion_id: scheme_mix_criterion_id)
    tasks += generate_certifier_member_tasks_12(user: user, project_id: project_id, certification_path_id: certification_path_id, scheme_mix_criterion_id: scheme_mix_criterion_id)
    tasks += generate_certifier_member_tasks_15(user: user, project_id: project_id, certification_path_id: certification_path_id, scheme_mix_criterion_id: scheme_mix_criterion_id)
    return tasks
  end

  def generate_system_admin_tasks_1(user:, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []

    # Query for certification_paths in 'registered' state and no certifier mngr assigned yet
    if project_id.present? && certification_path_id.blank?
      certification_paths = CertificationPath
                                .where(status: [CertificationPath.statuses[:registered]], project_id: project_id)
                                .where.not('exists(select pa.id from projects_users pa
                    where pa.project_id = certification_paths.project_id and pa.role = ?)', ProjectsUser.roles[:certifier_manager])
    else
      certification_paths = CertificationPath
                                .where(status: [CertificationPath.statuses[:registered]], id: certification_path_id)
                                .where.not('exists(select pa.id from projects_users pa
                    where pa.project_id = certification_paths.project_id and pa.role = ?)', ProjectsUser.roles[:certifier_manager])
    end
    certification_paths.each do |certification_path|
      task = Task.new(
          project_id: project_id,
          certification_path_id: certification_path.id,
          description_id: 1,
          resource_name: certification_path.name,
          resource_type: Task.resource_types[:certification_path])
      tasks << task
    end

    return tasks
  end

  def generate_system_admin_tasks_2(user:, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []

    # Query for certification_paths in 'registered' state and at least one certifier manager assigned
    if project_id.present? && certification_path_id.blank?
      certification_paths = CertificationPath
                                .where(status: [CertificationPath.statuses[:registered]], project_id: project_id)
                                .where('exists(select pa.id from projects_users pa
                where pa.project_id = certification_paths.project_id and pa.role = ?)', ProjectsUser.roles[:certifier_manager])
    else
      certification_paths = CertificationPath
                                .where(status: [CertificationPath.statuses[:registered]], id: certification_path_id)
                                .where('exists(select pa.id from projects_users pa
                where pa.project_id = certification_paths.project_id and pa.role = ?)', ProjectsUser.roles[:certifier_manager])
    end
    certification_paths.each do |certification_path|
      task = Task.new(
          project_id: project_id,
          certification_path_id: certification_path.id,
          description_id: 2,
          resource_name: certification_path.name,
          resource_type: Task.resource_types[:certification_path])
      tasks << task
    end

    return tasks
  end

  def generate_system_admin_tasks_11(user:, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []

    # Query for certification_paths in 'awaiting PCR admittance' state
    if project_id.present? && certification_path_id.blank?
      certification_paths = CertificationPath.where(status: [CertificationPath.statuses[:awaiting_pcr_admittance]], project_id: project_id)
    else
      certification_paths = CertificationPath.where(status: [CertificationPath.statuses[:awaiting_pcr_admittance]], id: certification_path_id)
    end
    certification_paths.each do |certification_path|
      task = Task.new(
          project_id: project_id,
          certification_path_id: certification_path.id,
          description_id: 11,
          resource_name: certification_path.name,
          resource_type: Task.resource_types[:certification_path])
      tasks << task
    end

    return tasks
  end

  def generate_gord_top_mngr_tasks_20(user:, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []

    # Query for certification_paths in 'awaiting signatures' state and not signed by top mngr yet
    if project_id.present? && certification_path_id.blank?
      certification_paths = CertificationPath.where(status: [CertificationPath.statuses[:awaiting_signatures]],
                                                    project_id: project_id,
                                                    signed_by_mngr: true,
                                                    signed_by_top_mngr: false)
    else
      certification_paths = CertificationPath.where(status: [CertificationPath.statuses[:awaiting_signatures]],
                                                    id: certification_path_id,
                                                    signed_by_mngr: true,
                                                    signed_by_top_mngr: false)
    end
    certification_paths.each do |certification_path|
      task = Task.new(
          project_id: project_id,
          certification_path_id: certification_path.id,
          description_id: 20,
          resource_name: certification_path.name,
          resource_type: Task.resource_types[:certification_path])
      tasks << task
    end

    return tasks
  end

  def generate_gord_top_mngr_tasks_21(user:, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []

    # Query for certification_paths in 'awaiting signatures' state and signed
    if project_id.present? && certification_path_id.blank?
      certification_paths = CertificationPath.where(status: [CertificationPath.statuses[:awaiting_signatures]],
                                                    project_id: project_id,
                                                    signed_by_mngr: true,
                                                    signed_by_top_mngr: true)
    else
      certification_paths = CertificationPath.where(status: [CertificationPath.statuses[:awaiting_signatures]],
                                                    id: certification_path_id,
                                                    signed_by_mngr: true,
                                                    signed_by_top_mngr: true)
    end
    certification_paths.each do |certification_path|
      task = Task.new(
          project_id: project_id,
          certification_path_id: certification_path.id,
          description_id: 21,
          resource_name: certification_path.name,
          resource_type: Task.resource_types[:certification_path])
      tasks << task
    end

    return tasks
  end

  def generate_gord_mngr_tasks_19(user:, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []

    # Query for certification_paths in 'awaiting signatures' state and not signed yet
    if project_id.present? && certification_path_id.blank?
      certification_paths = CertificationPath.where(status: [CertificationPath.statuses[:awaiting_signatures]],
                                                    project_id: project_id,
                                                    signed_by_mngr: false,
                                                    signed_by_top_mngr: false)
    else
      certification_paths = CertificationPath.where(status: [CertificationPath.statuses[:awaiting_signatures]],
                                                    id: certification_path_id,
                                                    signed_by_mngr: false,
                                                    signed_by_top_mngr: false)
    end
    certification_paths.each do |certification_path|
      task = Task.new(
          project_id: project_id,
          certification_path_id: certification_path.id,
          description_id: 19,
          resource_name: certification_path.name,
          resource_type: Task.resource_types[:certification_path])
      tasks << task
    end

    return tasks
  end

  def generate_project_mngr_tasks_3(user:, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []

    # Query for requirement_data in 'required' state and no project team member assigned yet
    if project_id.present? && certification_path_id.blank?
      requirement_data = RequirementDatum
                             .joins(:scheme_mix_criteria => [:scheme_mix => [:certification_path => [:project => [:projects_users]]]])
                             .where(status: [RequirementDatum.statuses[:required]], user: nil,
                                    certification_paths: {project_id: project_id},
                                    projects_users: {user_id: user.id, role: [ProjectsUser.roles[:project_manager]]})
    else
      requirement_data = RequirementDatum
                             .joins(:scheme_mix_criteria => [:scheme_mix => [:certification_path => [:project => [:projects_users]]]])
                             .where(status: [RequirementDatum.statuses[:required]], user: nil,
                                    certification_paths: {id: certification_path_id},
                                    projects_users: {user_id: user.id, role: [ProjectsUser.roles[:project_manager]]})
    end
    requirement_data.each do |requirement_datum|
      requirement_datum.scheme_mix_criteria.each do |scheme_mix_criterion|
        task = Task.new(
            project_id: project_id,
            certification_path_id: scheme_mix_criterion.scheme_mix.certification_path.id,
            scheme_mix_id: scheme_mix_criterion.scheme_mix.id,
            scheme_mix_criterion_id: scheme_mix_criterion.id,
            requirement_datum_id: requirement_datum.id,
            description_id: 3,
            resource_name: requirement_datum.requirement.name,
            resource_type: Task.resource_types[:requirement_datum]
        )
        tasks << task
      end
    end

    return tasks
  end

  def generate_project_mngr_tasks_5(user:, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []

    # Query for scheme_mix_criteria in 'in progress' state and no linked requirement_data in 'required' state
    if project_id.present? && certification_path_id.blank?
      scheme_mix_criteria = SchemeMixCriterion
                                .joins(:scheme_mix => [:certification_path => [:project => [:projects_users]]])
                                .where(status: [SchemeMixCriterion.statuses[:in_progress]],
                                       certification_paths: {project_id: project_id},
                                       projects_users: {user_id: user.id, role: [ProjectsUser.roles[:project_manager]]})
                                .where.not('exists(select rd.id from requirement_data rd
                    left join scheme_mix_criteria_requirement_data smcrd on smcrd.requirement_datum_id = rd.id
                    where smcrd.scheme_mix_criterion_id = scheme_mix_criteria.id and rd.status = ?)', RequirementDatum.statuses[:required])
    else
      scheme_mix_criteria = SchemeMixCriterion
                                .joins(:scheme_mix => [:certification_path => [:project => [:projects_users]]])
                                .where(status: [SchemeMixCriterion.statuses[:in_progress]],
                                       certification_paths: {id: certification_path_id},
                                       projects_users: {user_id: user.id, role: [ProjectsUser.roles[:project_manager]]})
                                .where.not('exists(select rd.id from requirement_data rd
                    left join scheme_mix_criteria_requirement_data smcrd on smcrd.requirement_datum_id = rd.id
                    where smcrd.scheme_mix_criterion_id = scheme_mix_criteria.id and rd.status = ?)', RequirementDatum.statuses[:required])
    end
    scheme_mix_criteria.each do |scheme_mix_criterion|
      task = Task.new(
          project_id: project_id,
          certification_path_id: scheme_mix_criterion.scheme_mix.certification_path.id,
          scheme_mix_id: scheme_mix_criterion.scheme_mix.id,
          scheme_mix_criterion_id: scheme_mix_criterion.id,
          description_id: 5,
          resource_name: scheme_mix_criterion.name,
          resource_type: Task.resource_types[:scheme_mix_criterion]
      )
      tasks << task
    end

    return tasks
  end

  def generate_project_mngr_tasks_6(user:, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []

    # Query for certification_paths in 'in submission' state and no linked scheme_mix_criteria in 'in progress' state
    if project_id.present? && certification_path_id.blank?
      certification_paths = CertificationPath
                                .joins(:project => [:projects_users])
                                .where(status: [CertificationPath.statuses[:in_submission]], project_id: project_id,
                                       projects_users: {user_id: user.id, role: [ProjectsUser.roles[:project_manager]]})
                                .where.not('exists(select smc.id from scheme_mix_criteria smc
                    left join scheme_mixes sm on sm.id = smc.scheme_mix_id
                    where sm.certification_path_id = certification_paths.id and smc.status = ?)', SchemeMixCriterion.statuses[:in_progress])
    else
      certification_paths = CertificationPath
                                .joins(:project => [:projects_users])
                                .where(status: [CertificationPath.statuses[:in_submission]], id: certification_path_id,
                                       projects_users: {user_id: user.id, role: [ProjectsUser.roles[:project_manager]]})
                                .where.not('exists(select smc.id from scheme_mix_criteria smc
                    left join scheme_mixes sm on sm.id = smc.scheme_mix_id
                    where sm.certification_path_id = certification_paths.id and smc.status = ?)', SchemeMixCriterion.statuses[:in_progress])
    end
    certification_paths.each do |certification_path|
      task = Task.new(
          project_id: project_id,
          certification_path_id: certification_path.id,
          description_id: 6,
          resource_name: certification_path.name,
          resource_type: Task.resource_types[:certification_path])
      tasks << task
    end

    return tasks
  end

  def generate_project_mngr_tasks_10(user:, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []

    # Query for certification_paths in 'screened' state
    if project_id.present? && certification_path_id.blank?
      certification_paths = CertificationPath
                                .joins(:project => [:projects_users])
                                .where(status: [CertificationPath.statuses[:screened]], project_id: project_id,
                                       projects_users: {user_id: user.id, role: [ProjectsUser.roles[:project_manager]]})
    else
      certification_paths = CertificationPath
                                .joins(:project => [:projects_users])
                                .where(status: [CertificationPath.statuses[:screened]], id: certification_path_id,
                                       projects_users: {user_id: user.id, role: [ProjectsUser.roles[:project_manager]]})
    end
    certification_paths.each do |certification_path|
      task = Task.new(
          project_id: project_id,
          certification_path_id: certification_path.id,
          description_id: 10,
          resource_name: certification_path.name,
          resource_type: Task.resource_types[:certification_path])
      tasks << task
    end

    return tasks
  end

  def generate_project_mngr_tasks_14(user:, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []

    # Query for certification_paths in 'reviewed' state
    if project_id.present? && certification_path_id.blank?
      certification_paths = CertificationPath
                                .joins(:project => [:projects_users])
                                .where(status: [CertificationPath.statuses[:reviewed]], project_id: project_id,
                                       projects_users: {user_id: user.id, role: [ProjectsUser.roles[:project_manager]]})
    else
      certification_paths = CertificationPath
                                .joins(:project => [:projects_users])
                                .where(status: [CertificationPath.statuses[:reviewed]], id: certification_path_id,
                                       projects_users: {user_id: user.id, role: [ProjectsUser.roles[:project_manager]]})
    end
    certification_paths.each do |certification_path|
      task = Task.new(
          project_id: project_id,
          certification_path_id: certification_path.id,
          description_id: 14,
          resource_name: certification_path.name,
          resource_type: Task.resource_types[:certification_path])
      tasks << task
    end

    return tasks
  end

  def generate_project_mngr_tasks_17(user:, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []

    # Query for certification_paths in 'certification rejected'
    if project_id.present? && certification_path_id.blank?
      certification_paths = CertificationPath
                                .joins(:project => [:projects_users])
                                .where(status: [CertificationPath.statuses[:certification_rejected]], project_id: project_id,
                                       projects_users: {user_id: user.id, role: [ProjectsUser.roles[:project_manager]]})
    else
      certification_paths = CertificationPath
                                .joins(:project => [:projects_users])
                                .where(status: [CertificationPath.statuses[:certification_rejected]], id: certification_path_id,
                                       projects_users: {user_id: user.id, role: [ProjectsUser.roles[:project_manager]]})
    end
    certification_paths.each do |certification_path|
      task = Task.new(
          project_id: project_id,
          certification_path_id: certification_path.id,
          description_id: 17,
          resource_name: certification_path.name,
          resource_type: Task.resource_types[:certification_path])
      tasks << task
    end

    return tasks
  end

  def generate_project_mngr_tasks_18(user:, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []

    # Query for certification_paths in 'awaiting approval'
    if project_id.present? && certification_path_id.blank?
      certification_paths = CertificationPath
                                .joins(:project => [:projects_users])
                                .where(status: [CertificationPath.statuses[:awaiting_approval]], project_id: project_id,
                                       projects_users: {user_id: user.id, role: [ProjectsUser.roles[:project_manager]]})
    else
      certification_paths = CertificationPath
                                .joins(:project => [:projects_users])
                                .where(status: [CertificationPath.statuses[:awaiting_approval]], id: certification_path_id,
                                       projects_users: {user_id: user.id, role: [ProjectsUser.roles[:project_manager]]})
    end
    certification_paths.each do |certification_path|
      task = Task.new(
          project_id: project_id,
          certification_path_id: certification_path.id,
          description_id: 18,
          resource_name: certification_path.name,
          resource_type: Task.resource_types[:certification_path])
      tasks << task
    end

    return tasks
  end

  def generate_project_mngr_tasks_22(user:, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []

    # Query for certification_paths in 'certified'
    if project_id.present? && certification_path_id.blank?
      certification_paths = CertificationPath
                                .joins(:project => [:projects_users])
                                .where(status: [CertificationPath.statuses[:certified]], project_id: project_id,
                                       projects_users: {user_id: user.id, role: [ProjectsUser.roles[:project_manager]]})
    else
      certification_paths = CertificationPath
                                .joins(:project => [:projects_users])
                                .where(status: [CertificationPath.statuses[:certified]], id: certification_path_id,
                                       projects_users: {user_id: user.id, role: [ProjectsUser.roles[:project_manager]]})
    end
    certification_paths.each do |certification_path|
      task = Task.new(
          project_id: project_id,
          certification_path_id: certification_path.id,
          description_id: 22,
          resource_name: certification_path.name,
          resource_type: Task.resource_types[:certification_path])
      tasks << task
    end

    return tasks
  end

  def generate_project_member_tasks_4(user:, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []

    # Query for requirement_data in 'required' state and project team member assigned
    if project_id.present? && certification_path_id.blank?
      requirement_data = RequirementDatum
                             .joins(:scheme_mix_criteria => [:scheme_mix => [:certification_path]])
                             .where(status: [RequirementDatum.statuses[:required]], user: user, certification_paths: {project_id: project_id})
    else
      requirement_data = RequirementDatum
                             .joins(:scheme_mix_criteria => [:scheme_mix => [:certification_path]])
                             .where(status: [RequirementDatum.statuses[:required]], user: user, certification_paths: {id: certification_path_id})
    end
    requirement_data.each do |requirement_datum|
      requirement_datum.scheme_mix_criteria.each do |scheme_mix_criterion|
        task = Task.new(
            project_id: project_id,
            certification_path_id: scheme_mix_criterion.scheme_mix.certification_path.id,
            scheme_mix_id: scheme_mix_criterion.scheme_mix.id,
            scheme_mix_criterion_id: scheme_mix_criterion.id,
            requirement_datum_id: requirement_datum.id,
            description_id: 4,
            resource_name: requirement_datum.requirement.name,
            resource_type: Task.resource_types[:requirement_datum]
        )
        tasks << task
      end
    end

    return tasks
  end

  def generate_certifier_mngr_tasks_7(user:, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []

    # Query for scheme_mix_criteria in 'complete' status and no certifier member assigned yet
    if project_id.present? && certification_path_id.blank?
      scheme_mix_criteria = SchemeMixCriterion
                                .joins(:scheme_mix => [:certification_path => [:project => [:projects_users]]])
                                .where(status: [SchemeMixCriterion.statuses[:complete]],
                                       certifier_id: nil,
                                       certification_paths: {status: [CertificationPath.statuses[:in_screening]], project_id: project_id},
                                       projects_users: {user_id: user.id, role: [ProjectsUser.roles[:certifier_manager]]})
    else
      scheme_mix_criteria = SchemeMixCriterion
                                .joins(:scheme_mix => [:certification_path => [:project => [:projects_users]]])
                                .where(status: [SchemeMixCriterion.statuses[:complete]],
                                       certifier_id: nil,
                                       certification_paths: {status: [CertificationPath.statuses[:in_screening]], id: certification_path_id},
                                       projects_users: {user_id: user.id, role: [ProjectsUser.roles[:certifier_manager]]})
    end
    scheme_mix_criteria.each do |scheme_mix_criterion|
      task = Task.new(
          project_id: project_id,
          certification_path_id: scheme_mix_criterion.scheme_mix.certification_path.id,
          scheme_mix_id: scheme_mix_criterion.scheme_mix.id,
          scheme_mix_criterion_id: scheme_mix_criterion.id,
          description_id: 7,
          resource_name: scheme_mix_criterion.name,
          resource_type: Task.resource_types[:scheme_mix_criterion]
      )
      tasks << task
    end

    return tasks
  end

  def generate_certifier_mngr_tasks_9(user:, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []

    # Query for certification_paths in 'in screening' state and no linked scheme_mix_criteria in 'complete' state
    if project_id.present? && certification_path_id.blank?
      certification_paths = CertificationPath
                                .joins(:project => [:projects_users])
                                .where(status: [CertificationPath.statuses[:in_screening]], project_id: project_id,
                                       projects_users: {user_id: user.id, role: [ProjectsUser.roles[:certifier_manager]]})
                                .where.not('exists(select smc.id from scheme_mix_criteria smc
                    left join scheme_mixes sm on sm.id = smc.scheme_mix_id
                    where sm.certification_path_id = certification_paths.id and smc.status = ?)', SchemeMixCriterion.statuses[:complete])
    else
      certification_paths = CertificationPath
                                .joins(:project => [:projects_users])
                                .where(status: [CertificationPath.statuses[:in_screening]], id: certification_path_id,
                                       projects_users: {user_id: user.id, role: [ProjectsUser.roles[:certifier_manager]]})
                                .where.not('exists(select smc.id from scheme_mix_criteria smc
                    left join scheme_mixes sm on sm.id = smc.scheme_mix_id
                    where sm.certification_path_id = certification_paths.id and smc.status = ?)', SchemeMixCriterion.statuses[:complete])
    end
    certification_paths.each do |certification_path|
      task = Task.new(
          project_id: project_id,
          certification_path_id: certification_path.id,
          description_id: 9,
          resource_name: certification_path.name,
          resource_type: Task.resource_types[:certification_path])
      tasks << task
    end

    return tasks
  end

  def generate_certifier_mngr_tasks_13(user:, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []

    # Query for certification_paths in 'in review' state all linked scheme_mix_criteria in 'reviewed_approved' or 'resubmit' state
    if project_id.present? && certification_path_id.blank?
      certification_paths = CertificationPath
                                .joins(:project => [:projects_users])
                                .where(status: [CertificationPath.statuses[:in_review]], project_id: project_id,
                                       projects_users: {user_id: user.id, role: [ProjectsUser.roles[:certifier_manager]]})
                                .where.not('exists(select smc.id from scheme_mix_criteria smc
                    left join scheme_mixes sm on sm.id = smc.scheme_mix_id
                    where sm.certification_path_id = certification_paths.id and smc.status = ?)', SchemeMixCriterion.statuses[:screened])
    else
      certification_paths = CertificationPath
                                .joins(:project => [:projects_users])
                                .where(status: [CertificationPath.statuses[:in_review]], id: certification_path_id,
                                       projects_users: {user_id: user.id, role: [ProjectsUser.roles[:certifier_manager]]})
                                .where.not('exists(select smc.id from scheme_mix_criteria smc
                    left join scheme_mixes sm on sm.id = smc.scheme_mix_id
                    where sm.certification_path_id = certification_paths.id and smc.status = ?)', SchemeMixCriterion.statuses[:screened])
    end
    certification_paths.each do |certification_path|
      task = Task.new(
          project_id: project_id,
          certification_path_id: certification_path.id,
          description_id: 13,
          resource_name: certification_path.name,
          resource_type: Task.resource_types[:certification_path])
      tasks << task
    end

    return tasks
  end

  def generate_certifier_mngr_tasks_16(user:, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []

    # Query for certification_paths in 'in verification' state all linked scheme_mix_criteria in 'verified_approved' or 'disapproved' state
    if project_id.present? && certification_path_id.blank?
      certification_paths = CertificationPath
                                .joins(:project => [:projects_users])
                                .where(status: [CertificationPath.statuses[:in_verification]], project_id: project_id,
                                       projects_users: {user_id: user.id, role: [ProjectsUser.roles[:certifier_manager]]})
                                .where.not('exists(select smc.id from scheme_mix_criteria smc
                    left join scheme_mixes sm on sm.id = smc.scheme_mix_id
                    where sm.certification_path_id = certification_paths.id and smc.status in (?, ?))', SchemeMixCriterion.statuses[:reviewed_approved], SchemeMixCriterion.statuses[:resubmit])
    else
      certification_paths = CertificationPath
                                .joins(:project => [:projects_users])
                                .where(status: [CertificationPath.statuses[:in_verification]], id: certification_path_id,
                                       projects_users: {user_id: user.id, role: [ProjectsUser.roles[:certifier_manager]]})
                                .where.not('exists(select smc.id from scheme_mix_criteria smc
                    left join scheme_mixes sm on sm.id = smc.scheme_mix_id
                    where sm.certification_path_id = certification_paths.id and smc.status in (?, ?))', SchemeMixCriterion.statuses[:reviewed_approved], SchemeMixCriterion.statuses[:resubmit])
    end
    certification_paths.each do |certification_path|
      task = Task.new(
          project_id: project_id,
          certification_path_id: certification_path.id,
          description_id: 16,
          resource_name: certification_path.name,
          resource_type: Task.resource_types[:certification_path])
      tasks << task
    end

    return tasks
  end

  def generate_certifier_member_tasks_8(user:, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []

    # Query for scheme_mix_criteria in 'complete' state and assigned certifier member
    if project_id.present? && certification_path_id.blank?
      scheme_mix_criteria = SchemeMixCriterion
                                .joins(:scheme_mix => [:certification_path])
                                .where(status: [SchemeMixCriterion.statuses[:complete]],
                                       certifier_id: user.id,
                                       certification_paths: {status: [CertificationPath.statuses[:in_screening]], project_id: project_id})
    else
      scheme_mix_criteria = SchemeMixCriterion
                                .joins(:scheme_mix => [:certification_path])
                                .where(status: [SchemeMixCriterion.statuses[:complete]],
                                       certifier_id: user.id,
                                       certification_paths: {id: certification_path_id, status: [CertificationPath.statuses[:in_screening]]})
    end
    scheme_mix_criteria.each do |scheme_mix_criterion|
      task = Task.new(
          project_id: project_id,
          certification_path_id: scheme_mix_criterion.scheme_mix.certification_path.id,
          scheme_mix_id: scheme_mix_criterion.scheme_mix.id,
          scheme_mix_criterion_id: scheme_mix_criterion.id,
          description_id: 8,
          resource_name: scheme_mix_criterion.name,
          resource_type: Task.resource_types[:scheme_mix_criterion]
      )
      tasks << task
    end

    return tasks
  end

  def generate_certifier_member_tasks_12(user:, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []

    # Query for scheme_mix_criteria not in 'reviewed_approved' or 'resubmit' state and assigned to certifier member
    if project_id.present? && certification_path_id.blank?
      scheme_mix_criteria = SchemeMixCriterion
                                .joins(:scheme_mix => [:certification_path])
                                .where(certifier_id: user.id,
                                       certification_paths: {status: [CertificationPath.statuses[:in_review]], project_id: project_id})
                                .where.not(status: [SchemeMixCriterion.statuses[:reviewed_approved], SchemeMixCriterion.statuses[:resubmit]])
    else
      scheme_mix_criteria = SchemeMixCriterion
                                .joins(:scheme_mix => [:certification_path])
                                .where(certifier_id: user.id,
                                       certification_paths: {id: certification_path_id, status: [CertificationPath.statuses[:in_review]]})
                                .where.not(status: [SchemeMixCriterion.statuses[:reviewed_approved], SchemeMixCriterion.statuses[:resubmit]])
    end
    scheme_mix_criteria.each do |scheme_mix_criterion|
      task = Task.new(
          project_id: project_id,
          certification_path_id: scheme_mix_criterion.scheme_mix.certification_path.id,
          scheme_mix_id: scheme_mix_criterion.scheme_mix.id,
          scheme_mix_criterion_id: scheme_mix_criterion.id,
          description_id: 12,
          resource_name: scheme_mix_criterion.name,
          resource_type: Task.resource_types[:scheme_mix_criterion]
      )
      tasks << task
    end

    return tasks
  end

  def generate_certifier_member_tasks_15(user:, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []

    # Query for scheme_mix_criteria not in 'verified_approved' or 'disapproved' state and assigned to certifier member
    if project_id.present? && certification_path_id.blank?
      scheme_mix_criteria = SchemeMixCriterion
                                .joins(:scheme_mix => [:certification_path])
                                .where(certifier_id: user.id,
                                       certification_paths: {status: [CertificationPath.statuses[:in_verification]], project_id: project_id})
                                .where.not(status: [SchemeMixCriterion.statuses[:verified_approved], SchemeMixCriterion.statuses[:resubmit]])
    else
      scheme_mix_criteria = SchemeMixCriterion
                                .joins(:scheme_mix => [:certification_path])
                                .where(certifier_id: user.id,
                                       certification_paths: {id: certification_path_id, status: [CertificationPath.statuses[:in_verification]]})
                                .where.not(status: [SchemeMixCriterion.statuses[:verified_approved], SchemeMixCriterion.statuses[:resubmit]])
    end
    scheme_mix_criteria.each do |scheme_mix_criterion|
      task = Task.new(
          project_id: project_id,
          certification_path_id: scheme_mix_criterion.scheme_mix.certification_path.id,
          scheme_mix_id: scheme_mix_criterion.scheme_mix.id,
          scheme_mix_criterion_id: scheme_mix_criterion.id,
          description_id: 15,
          resource_name: scheme_mix_criterion.name,
          resource_type: Task.resource_types[:scheme_mix_criterion]
      )
      tasks << task
    end

    return tasks
  end
end