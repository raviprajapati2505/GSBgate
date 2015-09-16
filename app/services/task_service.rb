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

    # Query for certification_paths in 'awaiting activation' state and no certifier mngr assigned yet
    if project_id.present? && certification_path_id.blank?
      certification_paths = CertificationPath
                                .where(status: [CertificationPath.statuses[:awaiting_activation]], project_id: project_id)
                                .where.not('exists(select pa.id from projects_users pa
                    where pa.project_id = certification_paths.project_id and pa.role = ?)', ProjectsUser.roles[:certifier_manager])
    else
      certification_paths = CertificationPath
                                .where(status: [CertificationPath.statuses[:awaiting_activation]], id: certification_path_id)
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

    # Query for certification_paths in 'awaiting activation' state and at least one certifier manager assigned
    if project_id.present? && certification_path_id.blank?
      certification_paths = CertificationPath
                                .where(status: [CertificationPath.statuses[:awaiting_activation]], project_id: project_id)
                                .where('exists(select pa.id from projects_users pa
                where pa.project_id = certification_paths.project_id and pa.role = ?)', ProjectsUser.roles[:certifier_manager])
    else
      certification_paths = CertificationPath
                                .where(status: [CertificationPath.statuses[:awaiting_activation]], id: certification_path_id)
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
    else
      certification_paths = CertificationPath.where(pcr_track: true, pcr_track_allowed: false, id: certification_path_id)
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
      certification_paths = CertificationPath.where(pcr_track_allowed: true, status: [CertificationPath.statuses[:awaiting_pcr_payment]], project_id: project_id)
    else
      certification_paths = CertificationPath.where(pcr_track_allowed: true, status: [CertificationPath.statuses[:awaiting_pcr_payment]], id: certification_path_id)
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

    # Query for certification_paths in 'awaiting appeal payment' state
    if project_id.present? && certification_path_id.blank?
      certification_paths = CertificationPath.where(status: [CertificationPath.statuses[:awaiting_appeal_payment]], project_id: project_id)
    else
      certification_paths = CertificationPath.where(status: [CertificationPath.statuses[:awaiting_appeal_payment]], id: certification_path_id)
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

    # Query for certification_paths in 'awaiting management approvals' state and not signed by top mngr yet
    if project_id.present? && certification_path_id.blank?
      certification_paths = CertificationPath.where(status: [CertificationPath.statuses[:awaiting_management_approvals]],
                                                    project_id: project_id,
                                                    signed_by_mngr: true,
                                                    signed_by_top_mngr: false)
    else
      certification_paths = CertificationPath.where(status: [CertificationPath.statuses[:awaiting_management_approvals]],
                                                    id: certification_path_id,
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

    # Query for certification_paths in 'awaiting management approvals' state and signed
    if project_id.present? && certification_path_id.blank?
      certification_paths = CertificationPath.where(status: [CertificationPath.statuses[:awaiting_management_approvals]],
                                                    project_id: project_id,
                                                    signed_by_mngr: true,
                                                    signed_by_top_mngr: true)
    else
      certification_paths = CertificationPath.where(status: [CertificationPath.statuses[:awaiting_management_approvals]],
                                                    id: certification_path_id,
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

    # Query for certification_paths in 'awaiting management approvals' state and not signed yet
    if project_id.present? && certification_path_id.blank?
      certification_paths = CertificationPath.where(status: [CertificationPath.statuses[:awaiting_management_approvals]],
                                                    project_id: project_id,
                                                    signed_by_mngr: false,
                                                    signed_by_top_mngr: false)
    else
      certification_paths = CertificationPath.where(status: [CertificationPath.statuses[:awaiting_management_approvals]],
                                                    id: certification_path_id,
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
    else
      requirement_data = RequirementDatum
                             .joins(:scheme_mix_criteria => [:scheme_mix => [:certification_path => [:project => [:projects_users]]]])
                             .where(status: [RequirementDatum.statuses[:required]], user: nil,
                                    certification_paths: {id: certification_path_id},
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
          model: scheme_mix_criterion,
          description_id: 5)
      tasks << task
    end

    return tasks
  end

  def generate_project_mngr_tasks_6(user: required, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []

    # Query for certification_paths in 'awaiting submission' state and no linked scheme_mix_criteria in 'in progress' state
    if project_id.present? && certification_path_id.blank?
      certification_paths = CertificationPath
                                .joins(:project => [:projects_users])
                                .where(status: [CertificationPath.statuses[:awaiting_submission],
                                                CertificationPath.statuses[:awaiting_submission_after_appeal]],
                                       project_id: project_id,
                                       projects_users: {user_id: user.id, role: [ProjectsUser.roles[:project_manager]]})
                                .where.not('exists(select smc.id from scheme_mix_criteria smc
                    left join scheme_mixes sm on sm.id = smc.scheme_mix_id
                    where sm.certification_path_id = certification_paths.id and smc.status = ?)', SchemeMixCriterion.statuses[:in_progress])
    else
      certification_paths = CertificationPath
                                .joins(:project => [:projects_users])
                                .where(status: [CertificationPath.statuses[:awaiting_submission],
                                                CertificationPath.statuses[:awaiting_submission_after_appeal]],
                                       id: certification_path_id,
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

    # Query for certification_paths in 'awaiting_submission_after_screening' state
    if project_id.present? && certification_path_id.blank?
      certification_paths = CertificationPath
                                .joins(:project => [:projects_users])
                                .where(status: [CertificationPath.statuses[:awaiting_submission_after_screening],
                                                CertificationPath.statuses[:awaiting_approval_or_appeal],
                                                CertificationPath.statuses[:awaiting_approval_after_appeal]],
                                       project_id: project_id,
                                       projects_users: {user_id: user.id, role: [ProjectsUser.roles[:project_manager]]})
    else
      certification_paths = CertificationPath
                                .joins(:project => [:projects_users])
                                .where(status: [CertificationPath.statuses[:awaiting_submission_after_screening],
                                                CertificationPath.statuses[:awaiting_approval_or_appeal],
                                                CertificationPath.statuses[:awaiting_approval_after_appeal]],
                                       id: certification_path_id,
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

    # Query for certification_paths in 'awaiting submission after pcr' state
    if project_id.present? && certification_path_id.blank?
      certification_paths = CertificationPath
                                .joins(:project => [:projects_users])
                                .where(status: [CertificationPath.statuses[:awaiting_submission_after_pcr]],
                                       project_id: project_id,
                                       projects_users: {user_id: user.id, role: [ProjectsUser.roles[:project_manager]]})
    else
      certification_paths = CertificationPath
                                .joins(:project => [:projects_users])
                                .where(status: [CertificationPath.statuses[:awaiting_submission_after_pcr]],
                                       id: certification_path_id,
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
    else
      scheme_mix_criteria_documents = SchemeMixCriteriaDocument
                                          .joins(:scheme_mix_criterion => [:scheme_mix => [:certification_path => [:project => [:projects_users]]]])
                                          .where(status: [SchemeMixCriteriaDocument.statuses[:awaiting_approval]],
                                                 certification_paths: {id: certification_path_id},
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
    else
      requirement_data = RequirementDatum
                             .joins(:scheme_mix_criteria => [:scheme_mix => [:certification_path]])
                             .where(status: [RequirementDatum.statuses[:required]],
                                    user: user, certification_paths: {id: certification_path_id})
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
    else
      scheme_mix_criteria = SchemeMixCriterion
                                .joins(:scheme_mix => [:certification_path => [:project => [:projects_users]]])
                                .where(certifier_id: nil,
                                       certification_paths: {id: certification_path_id},
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

    # Query for certification_paths in 'awaiting screening' state
    if project_id.present? && certification_path_id.blank?
      certification_paths = CertificationPath
                                .joins(:project => [:projects_users])
                                .where(status: [CertificationPath.statuses[:awaiting_screening],
                                                CertificationPath.statuses[:awaiting_submission_after_pcr]],
                                       project_id: project_id,
                                       projects_users: {user_id: user.id, role: [ProjectsUser.roles[:certifier_manager]]})
    else
      certification_paths = CertificationPath
                                .joins(:project => [:projects_users])
                                .where(status: [CertificationPath.statuses[:awaiting_screening],
                                                CertificationPath.statuses[:awaiting_submission_after_pcr]],
                                       id: certification_path_id,
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
                                .where(status: [CertificationPath.statuses[:awaiting_verification],
                                                CertificationPath.statuses[:awaiting_verification_after_appeal]],
                                       project_id: project_id,
                                       projects_users: {user_id: user.id, role: [ProjectsUser.roles[:certifier_manager]]})
                                .where.not('exists(select smc.id from scheme_mix_criteria smc
                    left join scheme_mixes sm on sm.id = smc.scheme_mix_id
                    where sm.certification_path_id = certification_paths.id and smc.status = ?)', SchemeMixCriterion.statuses[:complete])
    else
      certification_paths = CertificationPath
                                .joins(:project => [:projects_users])
                                .where(status: [CertificationPath.statuses[:awaiting_verification],
                                                CertificationPath.statuses[:awaiting_verification_after_appeal]],
                                       id: certification_path_id,
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
                                       certification_paths: {status: [CertificationPath.statuses[:awaiting_screening],
                                                                      CertificationPath.statuses[:awaiting_submission_after_pcr]],
                                                             project_id: project_id})
    else
      scheme_mix_criteria = SchemeMixCriterion
                                .joins(:scheme_mix => [:certification_path])
                                .where(status: [SchemeMixCriterion.statuses[:complete]],
                                       certifier_id: user.id,
                                       certification_paths: {id: certification_path_id,
                                                             status: [CertificationPath.statuses[:awaiting_screening],
                                                                      CertificationPath.statuses[:awaiting_submission_after_pcr]]})
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
                                       certification_paths: {status: [CertificationPath.statuses[:awaiting_verification],
                                                                      CertificationPath.statuses[:awaiting_verification_after_appeal]],
                                                             project_id: project_id})
                                .where.not(status: [SchemeMixCriterion.statuses[:approved], SchemeMixCriterion.statuses[:resubmit]])
    else
      scheme_mix_criteria = SchemeMixCriterion
                                .joins(:scheme_mix => [:certification_path])
                                .where(certifier_id: user.id,
                                       certification_paths: {id: certification_path_id,
                                                             status: [CertificationPath.statuses[:awaiting_verification],
                                                                      CertificationPath.statuses[:awaiting_verification_after_appeal]]})
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