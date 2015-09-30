class TaskService
  include Singleton

  def generate_tasks(user: required, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
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

  def generate_system_admin_tasks(user: required, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []
    tasks += generate_system_admin_tasks_1(user: user, project_id: project_id, certification_path_id: certification_path_id, scheme_mix_criterion_id: scheme_mix_criterion_id)
    tasks += generate_system_admin_tasks_2(user: user, project_id: project_id, certification_path_id: certification_path_id, scheme_mix_criterion_id: scheme_mix_criterion_id)
    tasks += generate_system_admin_tasks_11(user: user, project_id: project_id, certification_path_id: certification_path_id, scheme_mix_criterion_id: scheme_mix_criterion_id)
    tasks += generate_system_admin_tasks_12(user: user, project_id: project_id, certification_path_id: certification_path_id, scheme_mix_criterion_id: scheme_mix_criterion_id)
    tasks += generate_system_admin_tasks_19(user: user, project_id: project_id, certification_path_id: certification_path_id, scheme_mix_criterion_id: scheme_mix_criterion_id)
    return tasks
  end

  def generate_gord_top_mngr_tasks(user: required, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []
    tasks += generate_gord_top_mngr_tasks_26(user: user, project_id: project_id, certification_path_id: certification_path_id, scheme_mix_criterion_id: scheme_mix_criterion_id)
    tasks += generate_gord_top_mngr_tasks_27(user: user, project_id: project_id, certification_path_id: certification_path_id, scheme_mix_criterion_id: scheme_mix_criterion_id)
    return tasks
  end

  def generate_gord_mngr_tasks(user: required, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []
    tasks += generate_gord_mngr_tasks_25(user: user, project_id: project_id, certification_path_id: certification_path_id, scheme_mix_criterion_id: scheme_mix_criterion_id)
    return tasks
  end

  def generate_project_mngr_tasks(user: required, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []
    tasks += generate_project_mngr_tasks_3(user: user, project_id: project_id, certification_path_id: certification_path_id, scheme_mix_criterion_id: scheme_mix_criterion_id)
    tasks += generate_project_mngr_tasks_5(user: user, project_id: project_id, certification_path_id: certification_path_id, scheme_mix_criterion_id: scheme_mix_criterion_id)
    tasks += generate_project_mngr_tasks_6(user: user, project_id: project_id, certification_path_id: certification_path_id, scheme_mix_criterion_id: scheme_mix_criterion_id)
    tasks += generate_project_mngr_tasks_10(user: user, project_id: project_id, certification_path_id: certification_path_id, scheme_mix_criterion_id: scheme_mix_criterion_id)
    tasks += generate_project_mngr_tasks_15(user: user, project_id: project_id, certification_path_id: certification_path_id, scheme_mix_criterion_id: scheme_mix_criterion_id)
    tasks += generate_project_mngr_tasks_28(user: user, project_id: project_id, certification_path_id: certification_path_id, scheme_mix_criterion_id: scheme_mix_criterion_id)
    tasks += generate_project_mngr_tasks_29(user: user, project_id: project_id, certification_path_id: certification_path_id, scheme_mix_criterion_id: scheme_mix_criterion_id)
    return tasks
  end

  def generate_project_member_tasks(user: required, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []
    tasks += generate_project_member_tasks_4(user: user, project_id: project_id, certification_path_id: certification_path_id, scheme_mix_criterion_id: scheme_mix_criterion_id)
    return tasks
  end

  def generate_certifier_mngr_tasks(user: required, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []
    tasks += generate_certifier_mngr_tasks_7(user: user, project_id: project_id, certification_path_id: certification_path_id, scheme_mix_criterion_id: scheme_mix_criterion_id)
    tasks += generate_certifier_mngr_tasks_9(user: user, project_id: project_id, certification_path_id: certification_path_id, scheme_mix_criterion_id: scheme_mix_criterion_id)
    tasks += generate_certifier_mngr_tasks_17(user: user, project_id: project_id, certification_path_id: certification_path_id, scheme_mix_criterion_id: scheme_mix_criterion_id)
    return tasks
  end

  def generate_certifier_member_tasks(user: required, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []
    tasks += generate_certifier_member_tasks_8(user: user, project_id: project_id, certification_path_id: certification_path_id, scheme_mix_criterion_id: scheme_mix_criterion_id)
    tasks += generate_certifier_member_tasks_16(user: user, project_id: project_id, certification_path_id: certification_path_id, scheme_mix_criterion_id: scheme_mix_criterion_id)
    return tasks
  end

  private

  def generate_system_admin_tasks_1(user: required, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []

    # Query for certification_paths in 'activating' state and no certifier mngr assigned yet
    if project_id.present? && certification_path_id.blank?
      certification_paths = CertificationPath
                                .where(certification_path_status_id: CertificationPathStatus::ACTIVATING, project_id: project_id)
                                .where.not('exists(select pa.id from projects_users pa
                    where pa.project_id = certification_paths.project_id and pa.role = ?)', ProjectsUser.roles[:certifier_manager])
    elsif certification_path_id.present?
      certification_paths = CertificationPath
                                .where(certification_path_status_id: CertificationPathStatus::ACTIVATING, id: certification_path_id)
                                .where.not('exists(select pa.id from projects_users pa
                    where pa.project_id = certification_paths.project_id and pa.role = ?)', ProjectsUser.roles[:certifier_manager])
    else
      certification_paths = CertificationPath
                                .where(certification_path_status_id: CertificationPathStatus::ACTIVATING)
                                .where.not('exists(select pa.id from projects_users pa
                    where pa.project_id = certification_paths.project_id and pa.role = ?)', ProjectsUser.roles[:certifier_manager])
    end
    certification_paths.each do |certification_path|
      task = Task.new(
          model: certification_path,
          description_id: 1)
      tasks << task
    end

    return tasks
  end

  def generate_system_admin_tasks_2(user: required, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []

    # Query for certification_paths in 'activating' state and at least one certifier manager assigned
    if project_id.present? && certification_path_id.blank?
      certification_paths = CertificationPath
                                .where(certification_path_status_id: CertificationPathStatus::ACTIVATING, project_id: project_id)
                                .where('exists(select pa.id from projects_users pa
                where pa.project_id = certification_paths.project_id and pa.role = ?)', ProjectsUser.roles[:certifier_manager])
    elsif certification_path_id.present?
      certification_paths = CertificationPath
                                .where(certification_path_status_id: CertificationPathStatus::ACTIVATING, id: certification_path_id)
                                .where('exists(select pa.id from projects_users pa
                where pa.project_id = certification_paths.project_id and pa.role = ?)', ProjectsUser.roles[:certifier_manager])
    else
      certification_paths = CertificationPath
                                .where(certification_path_status_id: CertificationPathStatus::ACTIVATING)
                                .where('exists(select pa.id from projects_users pa
                where pa.project_id = certification_paths.project_id and pa.role = ?)', ProjectsUser.roles[:certifier_manager])
    end
    certification_paths.each do |certification_path|
      task = Task.new(
          model: certification_path,
          description_id: 2)
      tasks << task
    end

    return tasks
  end

  def generate_system_admin_tasks_11(user: required, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []

    # Query for certification_paths in 'awaiting PCR admittance' state
    if project_id.present? && certification_path_id.blank?
      certification_paths = CertificationPath.where(pcr_track: true, pcr_track_allowed: false, project_id: project_id)
    elsif certification_path_id.present?
      certification_paths = CertificationPath.where(pcr_track: true, pcr_track_allowed: false, id: certification_path_id)
    else
      certification_paths = CertificationPath.where(pcr_track: true, pcr_track_allowed: false)
    end
    certification_paths.each do |certification_path|
      task = Task.new(
          model: certification_path,
          description_id: 11)
      tasks << task
    end

    return tasks
  end

  def generate_system_admin_tasks_12(user: required, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []

    # Query for certification_paths in 'awaiting PCR admittance' state
    if project_id.present? && certification_path_id.blank?
      certification_paths = CertificationPath.where(pcr_track_allowed: true, certification_path_status_id: CertificationPathStatus::PROCESSING_PCR_PAYMENT, project_id: project_id)
    elsif certification_path_id.present?
      certification_paths = CertificationPath.where(pcr_track_allowed: true, certification_path_status_id: CertificationPathStatus::PROCESSING_PCR_PAYMENT, id: certification_path_id)
    else
      certification_paths = CertificationPath.where(pcr_track_allowed: true, certification_path_status_id: CertificationPathStatus::PROCESSING_PCR_PAYMENT)
    end
    certification_paths.each do |certification_path|
      task = Task.new(
          model: certification_path,
          description_id: 12)
      tasks << task
    end

    return tasks
  end

  def generate_system_admin_tasks_19(user: required, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []

    # Query for certification_paths in 'processing appeal payment' state
    if project_id.present? && certification_path_id.blank?
      certification_paths = CertificationPath.where(certification_path_status_id: CertificationPathStatus::PROCESSING_APPEAL_PAYMENT, project_id: project_id)
    elsif certification_path_id.present?
      certification_paths = CertificationPath.where(certification_path_status_id: CertificationPathStatus::PROCESSING_APPEAL_PAYMENT, id: certification_path_id)
    else
      certification_paths = CertificationPath.where(certification_path_status_id: CertificationPathStatus::PROCESSING_APPEAL_PAYMENT)
    end
    certification_paths.each do |certification_path|
      task = Task.new(
           model: certification_path,
           description_id: 19)
      tasks << task
    end

    return tasks
  end

  def generate_gord_top_mngr_tasks_26(user: required, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []

    # Query for certification_paths in 'approving by management' state and not signed by top mngr yet
    if project_id.present? && certification_path_id.blank?
      certification_paths = CertificationPath.where(certification_path_status_id: CertificationPathStatus::APPROVING_BY_MANAGEMENT,
                                                    project_id: project_id,
                                                    signed_by_mngr: true,
                                                    signed_by_top_mngr: false)
    elsif certification_path_id.present?
      certification_paths = CertificationPath.where(certification_path_status_id: CertificationPathStatus::APPROVING_BY_MANAGEMENT,
                                                    id: certification_path_id,
                                                    signed_by_mngr: true,
                                                    signed_by_top_mngr: false)
    else
      certification_paths = CertificationPath.where(certification_path_status_id: CertificationPathStatus::APPROVING_BY_MANAGEMENT,
                                                    signed_by_mngr: true,
                                                    signed_by_top_mngr: false)
    end
    certification_paths.each do |certification_path|
      task = Task.new(
          model: certification_path,
          description_id: 26)
      tasks << task
    end

    return tasks
  end

  def generate_gord_top_mngr_tasks_27(user: required, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []

    # Query for certification_paths in 'approving by management' state and signed
    if project_id.present? && certification_path_id.blank?
      certification_paths = CertificationPath.where(certification_path_status_id: CertificationPathStatus::APPROVING_BY_MANAGEMENT,
                                                    project_id: project_id,
                                                    signed_by_mngr: true,
                                                    signed_by_top_mngr: true)
    elsif certification_path_id.present?
      certification_paths = CertificationPath.where(certification_path_status_id: CertificationPathStatus::APPROVING_BY_MANAGEMENT,
                                                    id: certification_path_id,
                                                    signed_by_mngr: true,
                                                    signed_by_top_mngr: true)
    else
      certification_paths = CertificationPath.where(certification_path_status_id: CertificationPathStatus::APPROVING_BY_MANAGEMENT,
                                                    signed_by_mngr: true,
                                                    signed_by_top_mngr: true)
    end
    certification_paths.each do |certification_path|
      task = Task.new(
          model: certification_path,
          description_id: 27)
      tasks << task
    end

    return tasks
  end

  def generate_gord_mngr_tasks_25(user: required, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []

    # Query for certification_paths in 'approving by management' state and not signed yet
    if project_id.present? && certification_path_id.blank?
      certification_paths = CertificationPath.where(certification_path_status_id: CertificationPathStatus::APPROVING_BY_MANAGEMENT,
                                                    project_id: project_id,
                                                    signed_by_mngr: false,
                                                    signed_by_top_mngr: false)
    elsif certification_path_id.present?
      certification_paths = CertificationPath.where(certification_path_status_id: CertificationPathStatus::APPROVING_BY_MANAGEMENT,
                                                    id: certification_path_id,
                                                    signed_by_mngr: false,
                                                    signed_by_top_mngr: false)
    else
      certification_paths = CertificationPath.where(certification_path_status_id: CertificationPathStatus::APPROVING_BY_MANAGEMENT,
                                                    signed_by_mngr: false,
                                                    signed_by_top_mngr: false)
    end
    certification_paths.each do |certification_path|
      task = Task.new(
          model: certification_path,
          description_id: 25)
      tasks << task
    end

    return tasks
  end

  def generate_project_mngr_tasks_3(user: required, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []

    # Query for requirement_data in 'required' state and no project team member assigned yet
    if project_id.present? && certification_path_id.blank?
      requirement_data = RequirementDatum
                             .joins(:scheme_mix_criteria => [:scheme_mix => [:certification_path => [:project => [:projects_users]]]])
                             .where(status: [RequirementDatum.statuses[:required]], user: nil,
                                    certification_paths: {project_id: project_id},
                                    projects_users: {user_id: user.id, role: [ProjectsUser.roles[:project_manager]]})
    elsif certification_path_id.present?
      requirement_data = RequirementDatum
                             .joins(:scheme_mix_criteria => [:scheme_mix => [:certification_path => [:project => [:projects_users]]]])
                             .where(status: [RequirementDatum.statuses[:required]], user: nil,
                                    certification_paths: {id: certification_path_id},
                                    projects_users: {user_id: user.id, role: [ProjectsUser.roles[:project_manager]]})
    else
      requirement_data = RequirementDatum
                             .joins(:scheme_mix_criteria => [:scheme_mix => [:certification_path => [:project => [:projects_users]]]])
                             .where(status: [RequirementDatum.statuses[:required]], user: nil,
                                    projects_users: {user_id: user.id, role: [ProjectsUser.roles[:project_manager]]})
    end
    requirement_data.each do |requirement_datum|
      task = Task.new(
          model: requirement_datum,
          description_id: 3)
      tasks << task
    end

    return tasks
  end

  def generate_project_mngr_tasks_5(user: required, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
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
    elsif certification_path_id.present?
      scheme_mix_criteria = SchemeMixCriterion
                                .joins(:scheme_mix => [:certification_path => [:project => [:projects_users]]])
                                .where(status: [SchemeMixCriterion.statuses[:in_progress]],
                                       certification_paths: {id: certification_path_id},
                                       projects_users: {user_id: user.id, role: [ProjectsUser.roles[:project_manager]]})
                                .where.not('exists(select rd.id from requirement_data rd
                    left join scheme_mix_criteria_requirement_data smcrd on smcrd.requirement_datum_id = rd.id
                    where smcrd.scheme_mix_criterion_id = scheme_mix_criteria.id and rd.status = ?)', RequirementDatum.statuses[:required])
    else
      scheme_mix_criteria = SchemeMixCriterion
                                .joins(:scheme_mix => [:certification_path => [:project => [:projects_users]]])
                                .where(status: [SchemeMixCriterion.statuses[:in_progress]],
                                       projects_users: {user_id: user.id, role: [ProjectsUser.roles[:project_manager]]})
                                .where.not('exists(select rd.id from requirement_data rd
                    left join scheme_mix_criteria_requirement_data smcrd on smcrd.requirement_datum_id = rd.id
                    where smcrd.scheme_mix_criterion_id = scheme_mix_criteria.id and rd.status = ?)', RequirementDatum.statuses[:required])
    end
    scheme_mix_criteria.each do |scheme_mix_criterion|
      task = Task.new(
          model: scheme_mix_criterion,
          description_id: 5)
      tasks << task
    end

    return tasks
  end

  def generate_project_mngr_tasks_6(user: required, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []

    # Query for certification_paths in 'submitting' state and no linked scheme_mix_criteria in 'in progress' state
    if project_id.present? && certification_path_id.blank?
      certification_paths = CertificationPath
                                .joins(:project => [:projects_users])
                                .where(certification_path_status_id: [CertificationPathStatus::SUBMITTING,
                                                                      CertificationPathStatus::SUBMITTING_AFTER_APPEAL],
                                       project_id: project_id,
                                       projects_users: {user_id: user.id, role: [ProjectsUser.roles[:project_manager]]})
                                .where.not('exists(select smc.id from scheme_mix_criteria smc
                    left join scheme_mixes sm on sm.id = smc.scheme_mix_id
                    where sm.certification_path_id = certification_paths.id and smc.status = ?)', SchemeMixCriterion.statuses[:in_progress])
    elsif certification_path_id.present?
      certification_paths = CertificationPath
                                .joins(:project => [:projects_users])
                                .where(certification_path_status_id: [CertificationPathStatus::SUBMITTING,
                                                                      CertificationPathStatus::SUBMITTING_AFTER_APPEAL],
                                       id: certification_path_id,
                                       projects_users: {user_id: user.id, role: [ProjectsUser.roles[:project_manager]]})
                                .where.not('exists(select smc.id from scheme_mix_criteria smc
                    left join scheme_mixes sm on sm.id = smc.scheme_mix_id
                    where sm.certification_path_id = certification_paths.id and smc.status = ?)', SchemeMixCriterion.statuses[:in_progress])
    else
      certification_paths = CertificationPath
                                .joins(:project => [:projects_users])
                                .where(certification_path_status_id: [CertificationPathStatus::SUBMITTING,
                                                                      CertificationPathStatus::SUBMITTING_AFTER_APPEAL],
                                       projects_users: {user_id: user.id, role: [ProjectsUser.roles[:project_manager]]})
                                .where.not('exists(select smc.id from scheme_mix_criteria smc
                    left join scheme_mixes sm on sm.id = smc.scheme_mix_id
                    where sm.certification_path_id = certification_paths.id and smc.status = ?)', SchemeMixCriterion.statuses[:in_progress])
    end
    certification_paths.each do |certification_path|
      task = Task.new(
          model: certification_path,
          description_id: 6)
      tasks << task
    end

    return tasks
  end

  def generate_project_mngr_tasks_10(user: required, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []

    # Query for certification_paths in 'submitting after screening' or 'acknowledging' state
    if project_id.present? && certification_path_id.blank?
      certification_paths = CertificationPath
                                .joins(:project => [:projects_users])
                                .where(certification_path_status_id: [CertificationPathStatus::SUBMITTING_AFTER_SCREENING,
                                                                      CertificationPathStatus::ACKNOWLEDGING,
                                                                      CertificationPathStatus::ACKNOWLEDGING_AFTER_APPEAL],
                                       project_id: project_id,
                                       projects_users: {user_id: user.id, role: [ProjectsUser.roles[:project_manager]]})
    elsif certification_path_id.present?
      certification_paths = CertificationPath
                                .joins(:project => [:projects_users])
                                .where(certification_path_status_id: [CertificationPathStatus::SUBMITTING_AFTER_SCREENING,
                                                                      CertificationPathStatus::ACKNOWLEDGING,
                                                                      CertificationPathStatus::ACKNOWLEDGING_AFTER_APPEAL],
                                       id: certification_path_id,
                                       projects_users: {user_id: user.id, role: [ProjectsUser.roles[:project_manager]]})
    else
      certification_paths = CertificationPath
                                .joins(:project => [:projects_users])
                                .where(certification_path_status_id: [CertificationPathStatus::SUBMITTING_AFTER_SCREENING,
                                                                      CertificationPathStatus::ACKNOWLEDGING,
                                                                      CertificationPathStatus::ACKNOWLEDGING_AFTER_APPEAL],
                                       projects_users: {user_id: user.id, role: [ProjectsUser.roles[:project_manager]]})
    end
    certification_paths.each do |certification_path|
      task = Task.new(
          model: certification_path,
          description_id: 10)
      tasks << task
    end

    return tasks
  end

  def generate_project_mngr_tasks_15(user: required, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []

    # Query for certification_paths in 'submitting after pcr' state
    if project_id.present? && certification_path_id.blank?
      certification_paths = CertificationPath
                                .joins(:project => [:projects_users])
                                .where(certification_path_status_id: [CertificationPathStatus::SUBMITTING_PCR],
                                       project_id: project_id,
                                       projects_users: {user_id: user.id, role: [ProjectsUser.roles[:project_manager]]})
    elsif certification_path_id.present?
      certification_paths = CertificationPath
                                .joins(:project => [:projects_users])
                                .where(certification_path_status_id: [CertificationPathStatus::SUBMITTING_PCR],
                                       id: certification_path_id,
                                       projects_users: {user_id: user.id, role: [ProjectsUser.roles[:project_manager]]})
    else
      certification_paths = CertificationPath
                                .joins(:project => [:projects_users])
                                .where(certification_path_status_id: [CertificationPathStatus::SUBMITTING_PCR],
                                       projects_users: {user_id: user.id, role: [ProjectsUser.roles[:project_manager]]})
    end
    certification_paths.each do |certification_path|
      task = Task.new(
          model: certification_path,
          description_id: 15)
      tasks << task
    end

    return tasks
  end

  def generate_project_mngr_tasks_28(user: required, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []

    # Query for certification_paths in 'certified'
    if project_id.present? && certification_path_id.blank?
      certification_paths = CertificationPath
                                .joins(:project => [:projects_users])
                                .where(certification_path_status_id: [CertificationPathStatus::CERTIFIED], project_id: project_id,
                                       projects_users: {user_id: user.id, role: [ProjectsUser.roles[:project_manager]]})
    elsif certification_path_id.present?
      certification_paths = CertificationPath
                                .joins(:project => [:projects_users])
                                .where(certification_path_status_id: [CertificationPathStatus::CERTIFIED], id: certification_path_id,
                                       projects_users: {user_id: user.id, role: [ProjectsUser.roles[:project_manager]]})
    else
      certification_paths = CertificationPath
                                .joins(:project => [:projects_users])
                                .where(certification_path_status_id: [CertificationPathStatus::CERTIFIED],
                                       projects_users: {user_id: user.id, role: [ProjectsUser.roles[:project_manager]]})
    end
    certification_paths.each do |certification_path|
      task = Task.new(
          model: certification_path,
          description_id: 28)
      tasks << task
    end

    return tasks
  end

  def generate_project_mngr_tasks_29(user: required, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []

    if project_id.present? && certification_path_id.blank?
      scheme_mix_criteria_documents = SchemeMixCriteriaDocument
                                          .joins(:scheme_mix_criterion => [:scheme_mix => [:certification_path => [:project => [:projects_users]]]])
                                          .where(status: [SchemeMixCriteriaDocument.statuses[:awaiting_approval]],
                                                 certification_paths: {project_id: project_id},
                                                 projects_users: {user_id: user.id, role: [ProjectsUser.roles[:project_manager]]})
    elsif certification_path_id.present?
      scheme_mix_criteria_documents = SchemeMixCriteriaDocument
                                          .joins(:scheme_mix_criterion => [:scheme_mix => [:certification_path => [:project => [:projects_users]]]])
                                          .where(status: [SchemeMixCriteriaDocument.statuses[:awaiting_approval]],
                                                 certification_paths: {id: certification_path_id},
                                                 projects_users: {user_id: user.id, role: [ProjectsUser.roles[:project_manager]]})
    else
      scheme_mix_criteria_documents = SchemeMixCriteriaDocument
                                          .joins(:scheme_mix_criterion => [:scheme_mix => [:certification_path => [:project => [:projects_users]]]])
                                          .where(status: [SchemeMixCriteriaDocument.statuses[:awaiting_approval]],
                                                 projects_users: {user_id: user.id, role: [ProjectsUser.roles[:project_manager]]})
    end
    scheme_mix_criteria_documents.each do |document|
      task = Task.new(
                     model: document,
                     description_id: 29)
      tasks << task
    end

    return tasks
  end

  def generate_project_member_tasks_4(user: required, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []

    # Query for requirement_data in 'required' state and project team member assigned
    if project_id.present? && certification_path_id.blank?
      requirement_data = RequirementDatum
                             .joins(:scheme_mix_criteria => [:scheme_mix => [:certification_path]])
                             .where(status: [RequirementDatum.statuses[:required]],
                                    user: user, certification_paths: {project_id: project_id})
    elsif certification_path_id.present?
      requirement_data = RequirementDatum
                             .joins(:scheme_mix_criteria => [:scheme_mix => [:certification_path]])
                             .where(status: [RequirementDatum.statuses[:required]],
                                    user: user, certification_paths: {id: certification_path_id})
    else
      requirement_data = RequirementDatum
                             .where(status: [RequirementDatum.statuses[:required]],
                                    user: user)
    end
    requirement_data.each do |requirement_datum|
      task = Task.new(
          model: requirement_datum,
          description_id: 4)
      tasks << task
    end

    return tasks
  end

  def generate_certifier_mngr_tasks_7(user: required, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []

    # Query for scheme_mix_criteria with no certifier member assigned yet
    if project_id.present? && certification_path_id.blank?
      scheme_mix_criteria = SchemeMixCriterion
                                .joins(:scheme_mix => [:certification_path => [:project => [:projects_users]]])
                                .where(certifier_id: nil,
                                       certification_paths: {project_id: project_id},
                                       projects_users: {user_id: user.id, role: [ProjectsUser.roles[:certifier_manager]]})
    elsif certification_path_id.present?
      scheme_mix_criteria = SchemeMixCriterion
                                .joins(:scheme_mix => [:certification_path => [:project => [:projects_users]]])
                                .where(certifier_id: nil,
                                       certification_paths: {id: certification_path_id},
                                       projects_users: {user_id: user.id, role: [ProjectsUser.roles[:certifier_manager]]})
    else
      scheme_mix_criteria = SchemeMixCriterion
                                .joins(:scheme_mix => [:certification_path => [:project => [:projects_users]]])
                                .where(certifier_id: nil,
                                       projects_users: {user_id: user.id, role: [ProjectsUser.roles[:certifier_manager]]})
    end
    scheme_mix_criteria.each do |scheme_mix_criterion|
      task = Task.new(
          model: scheme_mix_criterion,
          description_id: 7)
      tasks << task
    end

    return tasks
  end

  def generate_certifier_mngr_tasks_9(user: required, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []

    # Query for certification_paths in 'screening' or 'submitting pcr' state
    if project_id.present? && certification_path_id.blank?
      certification_paths = CertificationPath
                                .joins(:project => [:projects_users])
                                .where(certification_path_status_id: [CertificationPathStatus::SCREENING,
                                                                      CertificationPathStatus::SUBMITTING_PCR],
                                       project_id: project_id,
                                       projects_users: {user_id: user.id, role: [ProjectsUser.roles[:certifier_manager]]})
    elsif certification_path_id.present?
      certification_paths = CertificationPath
                                .joins(:project => [:projects_users])
                                .where(certification_path_status_id: [CertificationPathStatus::SCREENING,
                                                                      CertificationPathStatus::SUBMITTING_PCR],
                                       id: certification_path_id,
                                       projects_users: {user_id: user.id, role: [ProjectsUser.roles[:certifier_manager]]})
    else
      certification_paths = CertificationPath
                                .joins(:project => [:projects_users])
                                .where(certification_path_status_id: [CertificationPathStatus::SCREENING,
                                                                      CertificationPathStatus::SUBMITTING_PCR],
                                       projects_users: {user_id: user.id, role: [ProjectsUser.roles[:certifier_manager]]})
    end
    certification_paths.each do |certification_path|
      task = Task.new(
          model: certification_path,
          description_id: 9)
      tasks << task
    end

    return tasks
  end

  def generate_certifier_mngr_tasks_17(user: required, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []

    # Query for certification_paths in 'awaiting verification' state
    if project_id.present? && certification_path_id.blank?
      certification_paths = CertificationPath
                                .joins(:project => [:projects_users])
                                .where(certification_path_status_id: [CertificationPathStatus::VERIFYING,
                                                                      CertificationPathStatus::VERIFYING_AFTER_APPEAL],
                                       project_id: project_id,
                                       projects_users: {user_id: user.id, role: [ProjectsUser.roles[:certifier_manager]]})
                                .where.not('exists(select smc.id from scheme_mix_criteria smc
                    left join scheme_mixes sm on sm.id = smc.scheme_mix_id
                    where sm.certification_path_id = certification_paths.id and smc.status = ?)', SchemeMixCriterion.statuses[:complete])
    elsif certification_path_id.present?
      certification_paths = CertificationPath
                                .joins(:project => [:projects_users])
                                .where(certification_path_status_id: [CertificationPathStatus::VERIFYING,
                                                                      CertificationPathStatus::VERIFYING_AFTER_APPEAL],
                                       id: certification_path_id,
                                       projects_users: {user_id: user.id, role: [ProjectsUser.roles[:certifier_manager]]})
                                .where.not('exists(select smc.id from scheme_mix_criteria smc
                    left join scheme_mixes sm on sm.id = smc.scheme_mix_id
                    where sm.certification_path_id = certification_paths.id and smc.status = ?)', SchemeMixCriterion.statuses[:complete])
    else
      certification_paths = CertificationPath
                                .joins(:project => [:projects_users])
                                .where(certification_path_status_id: [CertificationPathStatus::VERIFYING,
                                                                      CertificationPathStatus::VERIFYING_AFTER_APPEAL],
                                       projects_users: {user_id: user.id, role: [ProjectsUser.roles[:certifier_manager]]})
                                .where.not('exists(select smc.id from scheme_mix_criteria smc
                    left join scheme_mixes sm on sm.id = smc.scheme_mix_id
                    where sm.certification_path_id = certification_paths.id and smc.status = ?)', SchemeMixCriterion.statuses[:complete])
    end
    certification_paths.each do |certification_path|
      task = Task.new(
          model: certification_path,
          description_id: 17)
      tasks << task
    end

    return tasks
  end

  def generate_certifier_member_tasks_8(user: required, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []

    # Query for scheme_mix_criteria in 'complete' state and assigned certifier member
    if project_id.present? && certification_path_id.blank?
      scheme_mix_criteria = SchemeMixCriterion
                                .joins(:scheme_mix => [:certification_path])
                                .where(status: [SchemeMixCriterion.statuses[:complete]],
                                       certifier_id: user.id,
                                       certification_paths: {certification_path_status_id: [CertificationPathStatus::SCREENING,
                                                                                            CertificationPathStatus::SUBMITTING_PCR],
                                                             project_id: project_id})
    elsif certification_path_id.present?
      scheme_mix_criteria = SchemeMixCriterion
                                .joins(:scheme_mix => [:certification_path])
                                .where(status: [SchemeMixCriterion.statuses[:complete]],
                                       certifier_id: user.id,
                                       certification_paths: {id: certification_path_id,
                                                             certification_path_status_id: [CertificationPathStatus::SCREENING,
                                                                                            CertificationPathStatus::SUBMITTING_PCR]})
    else
      scheme_mix_criteria = SchemeMixCriterion
                                .joins(:scheme_mix => [:certification_path])
                                .where(status: [SchemeMixCriterion.statuses[:complete]],
                                       certifier_id: user.id,
                                       certification_paths: {certification_path_status_id: [CertificationPathStatus::SCREENING,
                                                                                             CertificationPathStatus::SUBMITTING_PCR]})
    end
    scheme_mix_criteria.each do |scheme_mix_criterion|
      task = Task.new(
          model: scheme_mix_criterion,
          description_id: 8)
      tasks << task
    end

    return tasks
  end

  def generate_certifier_member_tasks_16(user: required, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []

    # Query for scheme_mix_criteria not in 'approved' or 'resubmit' state and assigned to certifier member
    if project_id.present? && certification_path_id.blank?
      scheme_mix_criteria = SchemeMixCriterion
                                .joins(:scheme_mix => [:certification_path])
                                .where(certifier_id: user.id,
                                       certification_paths: {certification_path_status_id: [CertificationPathStatus::VERIFYING,
                                                                                            CertificationPathStatus::VERIFYING_AFTER_APPEAL],
                                                             project_id: project_id})
                                .where.not(status: [SchemeMixCriterion.statuses[:approved], SchemeMixCriterion.statuses[:resubmit]])
    elsif certification_path_id.present?
      scheme_mix_criteria = SchemeMixCriterion
                                .joins(:scheme_mix => [:certification_path])
                                .where(certifier_id: user.id,
                                       certification_paths: {id: certification_path_id,
                                                             certification_path_status_id: [CertificationPathStatus::VERIFYING,
                                                                                            CertificationPathStatus::VERIFYING_AFTER_APPEAL]})
                                .where.not(status: [SchemeMixCriterion.statuses[:approved], SchemeMixCriterion.statuses[:resubmit]])
    else
      scheme_mix_criteria = SchemeMixCriterion
                                .joins(:scheme_mix => [:certification_path])
                                .where(certifier_id: user.id,
                                       certification_paths: {certification_path_status_id: [CertificationPathStatus::VERIFYING,
                                                                                            CertificationPathStatus::VERIFYING_AFTER_APPEAL]})
                                .where.not(status: [SchemeMixCriterion.statuses[:approved], SchemeMixCriterion.statuses[:resubmit]])
    end
    scheme_mix_criteria.each do |scheme_mix_criterion|
      task = Task.new(
          model: scheme_mix_criterion,
          description_id: 16)
      tasks << task
    end

    return tasks
  end

end