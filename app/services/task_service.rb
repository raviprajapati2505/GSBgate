class TaskService
  include Singleton

  def generate_tasks(page: 1, per_page: 1, user: required, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []

    if user.system_admin?
      tasks += generate_system_admin_tasks(page: page,
                                           per_page: per_page,
                                           user: user,
                                           project_id: project_id,
                                           certification_path_id: certification_path_id,
                                           scheme_mix_criterion_id: scheme_mix_criterion_id)
    elsif user.gord_manager?
      tasks += generate_gord_mngr_tasks(page: page,
                                        per_page: per_page,
                                        user: user,
                                        project_id: project_id,
                                        certification_path_id: certification_path_id,
                                        scheme_mix_criterion_id: scheme_mix_criterion_id)
    elsif user.gord_top_manager?
      tasks += generate_gord_top_mngr_tasks(page: page,
                                            per_page: per_page,
                                            user: user,
                                            project_id: project_id,
                                            certification_path_id: certification_path_id,
                                            scheme_mix_criterion_id: scheme_mix_criterion_id)
    else
      tasks += generate_project_mngr_tasks(page: page,
                                           per_page: per_page,
                                           user: user,
                                           project_id: project_id,
                                           certification_path_id: certification_path_id,
                                           scheme_mix_criterion_id: scheme_mix_criterion_id)
      tasks += generate_project_member_tasks(page: page,
                                             per_page: per_page,
                                             user: user,
                                             project_id: project_id,
                                             certification_path_id: certification_path_id,
                                             scheme_mix_criterion_id: scheme_mix_criterion_id)
      tasks += generate_certifier_mngr_tasks(page: page,
                                             per_page: per_page,
                                             user: user,
                                             project_id: project_id,
                                             certification_path_id: certification_path_id,
                                             scheme_mix_criterion_id: scheme_mix_criterion_id)
      tasks += generate_certifier_member_tasks(page: page,
                                               per_page: per_page,
                                               user: user,
                                               project_id: project_id,
                                               certification_path_id: certification_path_id,
                                               scheme_mix_criterion_id: scheme_mix_criterion_id)
    end

    return tasks
  end

  def generate_system_admin_tasks(page: required, per_page: required, user: required, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []
    tasks += generate_system_admin_tasks_1(page: page, per_page: per_page, user: user, project_id: project_id, certification_path_id: certification_path_id, scheme_mix_criterion_id: scheme_mix_criterion_id)
    tasks += generate_system_admin_tasks_2(page: page, per_page: per_page, user: user, project_id: project_id, certification_path_id: certification_path_id, scheme_mix_criterion_id: scheme_mix_criterion_id)
    tasks += generate_system_admin_tasks_11(page: page, per_page: per_page, user: user, project_id: project_id, certification_path_id: certification_path_id, scheme_mix_criterion_id: scheme_mix_criterion_id)
    tasks += generate_system_admin_tasks_12(page: page, per_page: per_page, user: user, project_id: project_id, certification_path_id: certification_path_id, scheme_mix_criterion_id: scheme_mix_criterion_id)
    tasks += generate_system_admin_tasks_19(page: page, per_page: per_page, user: user, project_id: project_id, certification_path_id: certification_path_id, scheme_mix_criterion_id: scheme_mix_criterion_id)
    return tasks
  end

  def generate_gord_top_mngr_tasks(page: required, per_page: required, user: required, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []
    tasks += generate_gord_top_mngr_tasks_26(page: page, per_page: per_page, user: user, project_id: project_id, certification_path_id: certification_path_id, scheme_mix_criterion_id: scheme_mix_criterion_id)
    tasks += generate_gord_top_mngr_tasks_27(page: page, per_page: per_page, user: user, project_id: project_id, certification_path_id: certification_path_id, scheme_mix_criterion_id: scheme_mix_criterion_id)
    return tasks
  end

  def generate_gord_mngr_tasks(page: required, per_page: required, user: required, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []
    tasks += generate_gord_mngr_tasks_25(page: page, per_page: per_page, user: user, project_id: project_id, certification_path_id: certification_path_id, scheme_mix_criterion_id: scheme_mix_criterion_id)
    return tasks
  end

  def generate_project_mngr_tasks(page: required, per_page: required, user: required, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []
    tasks += generate_project_mngr_tasks_3(page: page, per_page: per_page, user: user, project_id: project_id, certification_path_id: certification_path_id, scheme_mix_criterion_id: scheme_mix_criterion_id)
    tasks += generate_project_mngr_tasks_5(page: page, per_page: per_page, user: user, project_id: project_id, certification_path_id: certification_path_id, scheme_mix_criterion_id: scheme_mix_criterion_id)
    tasks += generate_project_mngr_tasks_6(page: page, per_page: per_page, user: user, project_id: project_id, certification_path_id: certification_path_id, scheme_mix_criterion_id: scheme_mix_criterion_id)
    tasks += generate_project_mngr_tasks_10(page: page, per_page: per_page, user: user, project_id: project_id, certification_path_id: certification_path_id, scheme_mix_criterion_id: scheme_mix_criterion_id)
    tasks += generate_project_mngr_tasks_15(page: page, per_page: per_page, user: user, project_id: project_id, certification_path_id: certification_path_id, scheme_mix_criterion_id: scheme_mix_criterion_id)
    tasks += generate_project_mngr_tasks_28(page: page, per_page: per_page, user: user, project_id: project_id, certification_path_id: certification_path_id, scheme_mix_criterion_id: scheme_mix_criterion_id)
    tasks += generate_project_mngr_tasks_29(page: page, per_page: per_page, user: user, project_id: project_id, certification_path_id: certification_path_id, scheme_mix_criterion_id: scheme_mix_criterion_id)
    return tasks
  end

  def generate_project_member_tasks(page: required, per_page: required, user: required, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []
    tasks += generate_project_member_tasks_4(page: page, per_page: per_page, user: user, project_id: project_id, certification_path_id: certification_path_id, scheme_mix_criterion_id: scheme_mix_criterion_id)
    return tasks
  end

  def generate_certifier_mngr_tasks(page: required, per_page: required, user: required, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []
    tasks += generate_certifier_mngr_tasks_7(page: page, per_page: per_page, user: user, project_id: project_id, certification_path_id: certification_path_id, scheme_mix_criterion_id: scheme_mix_criterion_id)
    tasks += generate_certifier_mngr_tasks_9(page: page, per_page: per_page, user: user, project_id: project_id, certification_path_id: certification_path_id, scheme_mix_criterion_id: scheme_mix_criterion_id)
    tasks += generate_certifier_mngr_tasks_17(page: page, per_page: per_page, user: user, project_id: project_id, certification_path_id: certification_path_id, scheme_mix_criterion_id: scheme_mix_criterion_id)
    return tasks
  end

  def generate_certifier_member_tasks(page: required, per_page: required, user: required, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []
    tasks += generate_certifier_member_tasks_8(page: page, per_page: per_page, user: user, project_id: project_id, certification_path_id: certification_path_id, scheme_mix_criterion_id: scheme_mix_criterion_id)
    tasks += generate_certifier_member_tasks_16(page: page, per_page: per_page, user: user, project_id: project_id, certification_path_id: certification_path_id, scheme_mix_criterion_id: scheme_mix_criterion_id)
    return tasks
  end

  private

  def generate_system_admin_tasks_1(page: required, per_page: required, user: required, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []

    certification_paths = CertificationPath
                              .where(status: [CertificationPath.statuses[:awaiting_activation]])
                              .where.not('exists(select pa.id from projects_users pa
                    where pa.project_id = certification_paths.project_id and pa.role = ?)', ProjectsUser.roles[:certifier_manager])

    # Query for certification_paths in 'awaiting activation' state and no certifier mngr assigned yet
    if project_id.present? && certification_path_id.blank?
      certification_paths = certification_paths
                                .where(project_id: project_id)
    elsif certification_path_id.present?
      certification_paths = certification_paths
                                .where(id: certification_path_id)
    end
    certification_paths.paginate page: page, per_page: per_page
    certification_paths.each do |certification_path|
      task = Task.new(
          model: certification_path,
          description_id: 1)
      tasks << task
    end

    return tasks
  end

  def generate_system_admin_tasks_2(page: required, per_page: required, user: required, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []

    certification_paths = CertificationPath
                              .where(status: [CertificationPath.statuses[:awaiting_activation]])
                              .where('exists(select pa.id from projects_users pa
                where pa.project_id = certification_paths.project_id and pa.role = ?)', ProjectsUser.roles[:certifier_manager])

    # Query for certification_paths in 'awaiting activation' state and at least one certifier manager assigned
    if project_id.present? && certification_path_id.blank?
      certification_paths = certification_paths
                                .where(project_id: project_id)
    elsif certification_path_id.present?
      certification_paths = certification_paths
                                .where(id: certification_path_id)
    end
    certification_paths.paginate page: page, per_page: per_page
    certification_paths.each do |certification_path|
      task = Task.new(
          model: certification_path,
          description_id: 2)
      tasks << task
    end

    return tasks
  end

  def generate_system_admin_tasks_11(page: required, per_page: required, user: required, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []

    certification_paths = CertificationPath.where(pcr_track: true, pcr_track_allowed: false)

    # Query for certification_paths in 'awaiting PCR admittance' state
    if project_id.present? && certification_path_id.blank?
      certification_paths = certification_paths.where(project_id: project_id)
    elsif certification_path_id.present?
      certification_paths = certification_paths.where(id: certification_path_id)
    end
    certification_paths.paginate page: page, per_page: per_page
    certification_paths.each do |certification_path|
      task = Task.new(
          model: certification_path,
          description_id: 11)
      tasks << task
    end

    return tasks
  end

  def generate_system_admin_tasks_12(page: required, per_page: required, user: required, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []

    certification_paths = CertificationPath.where(pcr_track_allowed: true, status: [CertificationPath.statuses[:awaiting_pcr_payment]])

    # Query for certification_paths in 'awaiting PCR admittance' state
    if project_id.present? && certification_path_id.blank?
      certification_paths = certification_paths.where(project_id: project_id)
    elsif certification_path_id.present?
      certification_paths = certification_paths.where(id: certification_path_id)
    end
    certification_paths.paginate page: page, per_page: per_page
    certification_paths.each do |certification_path|
      task = Task.new(
          model: certification_path,
          description_id: 12)
      tasks << task
    end

    return tasks
  end

  def generate_system_admin_tasks_19(page: required, per_page: required, user: required, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []

    certification_paths = CertificationPath.where(status: [CertificationPath.statuses[:awaiting_appeal_payment]])

    # Query for certification_paths in 'awaiting appeal payment' state
    if project_id.present? && certification_path_id.blank?
      certification_paths = certification_paths.where(project_id: project_id)
    elsif certification_path_id.present?
      certification_paths = certification_paths.where(id: certification_path_id)
    end
    certification_paths.paginate page: page, per_page: per_page
    certification_paths.each do |certification_path|
      task = Task.new(
           model: certification_path,
           description_id: 19)
      tasks << task
    end

    return tasks
  end

  def generate_gord_top_mngr_tasks_26(page: required, per_page: required, user: required, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []

    certification_paths = CertificationPath.where(status: [CertificationPath.statuses[:awaiting_management_approvals]],
                                                  signed_by_mngr: true,
                                                  signed_by_top_mngr: false)

    # Query for certification_paths in 'awaiting management approvals' state and not signed by top mngr yet
    if project_id.present? && certification_path_id.blank?
      certification_paths = certification_paths.where(project_id: project_id)
    elsif certification_path_id.present?
      certification_paths = certification_paths.where(id: certification_path_id)
    end
    certification_paths.paginate page: page, per_page: per_page
    certification_paths.each do |certification_path|
      task = Task.new(
          model: certification_path,
          description_id: 26)
      tasks << task
    end

    return tasks
  end

  def generate_gord_top_mngr_tasks_27(page: required, per_page: required, user: required, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []

    certification_paths = CertificationPath.where(status: [CertificationPath.statuses[:awaiting_management_approvals]],
                                                  signed_by_mngr: true,
                                                  signed_by_top_mngr: true)

    # Query for certification_paths in 'awaiting management approvals' state and signed
    if project_id.present? && certification_path_id.blank?
      certification_paths = certification_paths.where(project_id: project_id)
    elsif certification_path_id.present?
      certification_paths = certification_paths.where(id: certification_path_id)
    end
    certification_paths.paginate page: page, per_page: per_page
    certification_paths.each do |certification_path|
      task = Task.new(
          model: certification_path,
          description_id: 27)
      tasks << task
    end

    return tasks
  end

  def generate_gord_mngr_tasks_25(page: required, per_page: required, user: required, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []

    certification_paths = CertificationPath.where(status: [CertificationPath.statuses[:awaiting_management_approvals]],
                                                  signed_by_mngr: false,
                                                  signed_by_top_mngr: false)

    # Query for certification_paths in 'awaiting management approvals' state and not signed yet
    if project_id.present? && certification_path_id.blank?
      certification_paths = certification_paths.where(project_id: project_id)
    elsif certification_path_id.present?
      certification_paths = certification_paths.where(id: certification_path_id)
    end
    certification_paths.paginate page: page, per_page: per_page
    certification_paths.each do |certification_path|
      task = Task.new(
          model: certification_path,
          description_id: 25)
      tasks << task
    end

    return tasks
  end

  def generate_project_mngr_tasks_3(page: required, per_page: required, user: required, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []

    requirement_data = RequirementDatum
                           .joins(:scheme_mix_criteria => [:scheme_mix => [:certification_path => [:project => [:projects_users]]]])
                           .where(status: [RequirementDatum.statuses[:required]], user: nil,
                                  projects_users: {user_id: user.id, role: [ProjectsUser.roles[:project_manager]]})

    # Query for requirement_data in 'required' state and no project team member assigned yet
    if project_id.present? && certification_path_id.blank?
      requirement_data = requirement_data
                             .where(certification_paths: {project_id: project_id})
    elsif certification_path_id.present?
      requirement_data = requirement_data
                             .where(certification_paths: {id: certification_path_id})
    end
    requirement_data.paginate page: page, per_page: per_page
    requirement_data.each do |requirement_datum|
      task = Task.new(
          model: requirement_datum,
          description_id: 3)
      tasks << task
    end

    return tasks
  end

  def generate_project_mngr_tasks_5(page: required, per_page: required, user: required, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []

    scheme_mix_criteria = SchemeMixCriterion
                              .joins(:scheme_mix => [:certification_path => [:project => [:projects_users]]])
                              .where(status: [SchemeMixCriterion.statuses[:in_progress]],
                                     projects_users: {user_id: user.id, role: [ProjectsUser.roles[:project_manager]]})
                              .where.not('exists(select rd.id from requirement_data rd
                    left join scheme_mix_criteria_requirement_data smcrd on smcrd.requirement_datum_id = rd.id
                    where smcrd.scheme_mix_criterion_id = scheme_mix_criteria.id and rd.status = ?)', RequirementDatum.statuses[:required])

    # Query for scheme_mix_criteria in 'in progress' state and no linked requirement_data in 'required' state
    if project_id.present? && certification_path_id.blank?
      scheme_mix_criteria = scheme_mix_criteria
                                .where(certification_paths: {project_id: project_id})
    elsif certification_path_id.present?
      scheme_mix_criteria = scheme_mix_criteria
                                .where(certification_paths: {id: certification_path_id})
    end
    scheme_mix_criteria.paginate page: page, per_page: per_page
    scheme_mix_criteria.each do |scheme_mix_criterion|
      task = Task.new(
          model: scheme_mix_criterion,
          description_id: 5)
      tasks << task
    end

    return tasks
  end

  def generate_project_mngr_tasks_6(page: required, per_page: required, user: required, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []

    certification_paths = CertificationPath
                              .joins(:project => [:projects_users])
                              .where(status: [CertificationPath.statuses[:awaiting_submission],
                                              CertificationPath.statuses[:awaiting_submission_after_appeal]],
                                     projects_users: {user_id: user.id, role: [ProjectsUser.roles[:project_manager]]})
                              .where.not('exists(select smc.id from scheme_mix_criteria smc
                    left join scheme_mixes sm on sm.id = smc.scheme_mix_id
                    where sm.certification_path_id = certification_paths.id and smc.status = ?)', SchemeMixCriterion.statuses[:in_progress])

    # Query for certification_paths in 'awaiting submission' state and no linked scheme_mix_criteria in 'in progress' state
    if project_id.present? && certification_path_id.blank?
      certification_paths = certification_paths
                                .where(project_id: project_id)
    elsif certification_path_id.present?
      certification_paths = certification_paths
                                .where(id: certification_path_id)
    end
    certification_paths.paginate page: page, per_page: per_page
    certification_paths.each do |certification_path|
      task = Task.new(
          model: certification_path,
          description_id: 6)
      tasks << task
    end

    return tasks
  end

  def generate_project_mngr_tasks_10(page: required, per_page: required, user: required, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []

    certification_paths = CertificationPath
                              .joins(:project => [:projects_users])
                              .where(status: [CertificationPath.statuses[:awaiting_submission_after_screening],
                                              CertificationPath.statuses[:awaiting_approval_or_appeal],
                                              CertificationPath.statuses[:awaiting_approval_after_appeal]],
                                     projects_users: {user_id: user.id, role: [ProjectsUser.roles[:project_manager]]})

    # Query for certification_paths in 'awaiting_submission_after_screening' state
    if project_id.present? && certification_path_id.blank?
      certification_paths = certification_paths
                                .where(project_id: project_id)
    elsif certification_path_id.present?
      certification_paths = certification_paths
                                .where(id: certification_path_id)
    end
    certification_paths.paginate page: page, per_page: per_page
    certification_paths.each do |certification_path|
      task = Task.new(
          model: certification_path,
          description_id: 10)
      tasks << task
    end

    return tasks
  end

  def generate_project_mngr_tasks_15(page: required, per_page: required, user: required, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []

    certification_paths = CertificationPath
                              .joins(:project => [:projects_users])
                              .where(status: [CertificationPath.statuses[:awaiting_submission_after_pcr]],
                                     projects_users: {user_id: user.id, role: [ProjectsUser.roles[:project_manager]]})

    # Query for certification_paths in 'awaiting submission after pcr' state
    if project_id.present? && certification_path_id.blank?
      certification_paths = certification_paths
                                .where(project_id: project_id)
    elsif certification_path_id.present?
      certification_paths = certification_paths
                                .where(id: certification_path_id)
    end
    certification_paths.paginate page: page, per_page: per_page
    certification_paths.each do |certification_path|
      task = Task.new(
          model: certification_path,
          description_id: 15)
      tasks << task
    end

    return tasks
  end

  def generate_project_mngr_tasks_28(page: required, per_page: required, user: required, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []

    certification_paths = CertificationPath
                              .joins(:project => [:projects_users])
                              .where(status: [CertificationPath.statuses[:certified]],
                                     projects_users: {user_id: user.id, role: [ProjectsUser.roles[:project_manager]]})

    # Query for certification_paths in 'certified'
    if project_id.present? && certification_path_id.blank?
      certification_paths = certification_paths
                                .where(project_id: project_id)
    elsif certification_path_id.present?
      certification_paths = certification_paths
                                .where(id: certification_path_id)
    end
    certification_paths.paginate page: page, per_page: per_page
    certification_paths.each do |certification_path|
      task = Task.new(
          model: certification_path,
          description_id: 28)
      tasks << task
    end

    return tasks
  end

  def generate_project_mngr_tasks_29(page: required, per_page: required, user: required, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []

    scheme_mix_criteria_documents = SchemeMixCriteriaDocument
                                        .joins(:scheme_mix_criterion => [:scheme_mix => [:certification_path => [:project => [:projects_users]]]])
                                        .where(status: [SchemeMixCriteriaDocument.statuses[:awaiting_approval]],
                                               projects_users: {user_id: user.id, role: [ProjectsUser.roles[:project_manager]]})

    # Query for scheme_mix_criteria_documents in 'awaiting approval'
    if project_id.present? && certification_path_id.blank?
      scheme_mix_criteria_documents = scheme_mix_criteria_documents
                                          .where(certification_paths: {project_id: project_id})
    elsif certification_path_id.present?
      scheme_mix_criteria_documents = scheme_mix_criteria_documents
                                          .where(certification_paths: {id: certification_path_id})
    end
    scheme_mix_criteria_documents.paginate page: page, per_page: per_page
    scheme_mix_criteria_documents.each do |document|
      task = Task.new(
                     model: document,
                     description_id: 29)
      tasks << task
    end

    return tasks
  end

  def generate_project_member_tasks_4(page: required, per_page: required, user: required, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []

    requirement_data = RequirementDatum
                           .joins(:scheme_mix_criteria => [:scheme_mix => [:certification_path]])
                           .where(status: [RequirementDatum.statuses[:required]],
                                  user: user)

    # Query for requirement_data in 'required' state and project team member assigned
    if project_id.present? && certification_path_id.blank?
      requirement_data = requirement_data
                             .where(certification_paths: {project_id: project_id})
    elsif certification_path_id.present?
      requirement_data = requirement_data
                             .where(certification_paths: {id: certification_path_id})
    end
    requirement_data.paginate page: page, per_page: per_page
    requirement_data.each do |requirement_datum|
      task = Task.new(
          model: requirement_datum,
          description_id: 4)
      tasks << task
    end

    return tasks
  end

  def generate_certifier_mngr_tasks_7(page: required, per_page: required, user: required, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []

    scheme_mix_criteria = SchemeMixCriterion
                              .joins(:scheme_mix => [:certification_path => [:project => [:projects_users]]])
                              .where(certifier_id: nil,
                                     projects_users: {user_id: user.id, role: [ProjectsUser.roles[:certifier_manager]]})

    # Query for scheme_mix_criteria with no certifier member assigned yet
    if project_id.present? && certification_path_id.blank?
      scheme_mix_criteria = scheme_mix_criteria
                                .where(certification_paths: {project_id: project_id})
    elsif certification_path_id.present?
      scheme_mix_criteria = scheme_mix_criteria
                                .where(certification_paths: {id: certification_path_id})
    end
    scheme_mix_criteria.paginate page: page, per_page: per_page
    scheme_mix_criteria.each do |scheme_mix_criterion|
      task = Task.new(
          model: scheme_mix_criterion,
          description_id: 7)
      tasks << task
    end

    return tasks
  end

  def generate_certifier_mngr_tasks_9(page: required, per_page: required, user: required, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []

    certification_paths = CertificationPath
                              .joins(:project => [:projects_users])
                              .where(status: [CertificationPath.statuses[:awaiting_screening],
                                              CertificationPath.statuses[:awaiting_submission_after_pcr]],
                                     projects_users: {user_id: user.id, role: [ProjectsUser.roles[:certifier_manager]]})

    # Query for certification_paths in 'awaiting screening' state
    if project_id.present? && certification_path_id.blank?
      certification_paths = certification_paths
                                .where(project_id: project_id)
    elsif certification_path_id.present?
      certification_paths = certification_paths
                                .where(id: certification_path_id)
    end
    certification_paths.paginate page: page, per_page: per_page
    certification_paths.each do |certification_path|
      task = Task.new(
          model: certification_path,
          description_id: 9)
      tasks << task
    end

    return tasks
  end

  def generate_certifier_mngr_tasks_17(page: required, per_page: required, user: required, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []

    certification_paths = CertificationPath
                             .joins(:project => [:projects_users])
                             .where(status: [CertificationPath.statuses[:awaiting_verification],
                                             CertificationPath.statuses[:awaiting_verification_after_appeal]],
                                    projects_users: {user_id: user.id, role: [ProjectsUser.roles[:certifier_manager]]})
                              .where.not('exists(select smc.id from scheme_mix_criteria smc
                    left join scheme_mixes sm on sm.id = smc.scheme_mix_id
                    where sm.certification_path_id = certification_paths.id and smc.status = ?)', SchemeMixCriterion.statuses[:complete])

    # Query for certification_paths in 'awaiting verification' state
    if project_id.present? && certification_path_id.blank?
      certification_paths = certification_paths
                                .where(project_id: project_id)
    elsif certification_path_id.present?
      certification_paths = certification_paths
                                .where(id: certification_path_id)
    end
    certification_paths.paginate page: page, per_page: per_page
    certification_paths.each do |certification_path|
      task = Task.new(
          model: certification_path,
          description_id: 17)
      tasks << task
    end

    return tasks
  end

  def generate_certifier_member_tasks_8(page: required, per_page: required, user: required, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []

    scheme_mix_criteria = SchemeMixCriterion
                              .joins(:scheme_mix => [:certification_path])
                              .where(status: [SchemeMixCriterion.statuses[:complete]],
                                     certifier_id: user.id)

    # Query for scheme_mix_criteria in 'complete' state and assigned certifier member
    if project_id.present? && certification_path_id.blank?
      scheme_mix_criteria = scheme_mix_criteria
                                .where(certification_paths: {status: [CertificationPath.statuses[:awaiting_screening],
                                                                      CertificationPath.statuses[:awaiting_submission_after_pcr]],
                                                             project_id: project_id})
    elsif certification_path_id.present?
      scheme_mix_criteria = scheme_mix_criteria
                                .where(certification_paths: {id: certification_path_id,
                                                             status: [CertificationPath.statuses[:awaiting_screening],
                                                                      CertificationPath.statuses[:awaiting_submission_after_pcr]]})
    else
      scheme_mix_criteria = scheme_mix_criteria
                                .where(certification_paths: {status: [CertificationPath.statuses[:awaiting_screening],
                                                                      CertificationPath.statuses[:awaiting_submission_after_pcr]]})
    end
    scheme_mix_criteria.paginate page: page, per_page: per_page
    scheme_mix_criteria.each do |scheme_mix_criterion|
      task = Task.new(
          model: scheme_mix_criterion,
          description_id: 8)
      tasks << task
    end

    return tasks
  end

  def generate_certifier_member_tasks_16(page: required, per_page: required, user: required, project_id: nil, certification_path_id: nil, scheme_mix_criterion_id: nil)
    tasks = []

    scheme_mix_criteria = SchemeMixCriterion
                              .joins(:scheme_mix => [:certification_path])
                              .where(certifier_id: user.id)
                              .where.not(status: [SchemeMixCriterion.statuses[:approved], SchemeMixCriterion.statuses[:resubmit]])

    # Query for scheme_mix_criteria not in 'approved' or 'resubmit' state and assigned to certifier member
    if project_id.present? && certification_path_id.blank?
      scheme_mix_criteria = scheme_mix_criteria
                                .where(certification_paths: {status: [CertificationPath.statuses[:awaiting_verification],
                                                                      CertificationPath.statuses[:awaiting_verification_after_appeal]],
                                                             project_id: project_id})
    elsif certification_path_id.present?
      scheme_mix_criteria = scheme_mix_criteria
                                .where(certification_paths: {id: certification_path_id,
                                                             status: [CertificationPath.statuses[:awaiting_verification],
                                                                      CertificationPath.statuses[:awaiting_verification_after_appeal]]})
    else
      scheme_mix_criteria = scheme_mix_criteria
                                .where(certification_paths: {status: [CertificationPath.statuses[:awaiting_verification],
                                                                      CertificationPath.statuses[:awaiting_verification_after_appeal]]})
    end
    scheme_mix_criteria.paginate page: page, per_page: per_page
    scheme_mix_criteria.each do |scheme_mix_criterion|
      task = Task.new(
          model: scheme_mix_criterion,
          description_id: 16)
      tasks << task
    end

    return tasks
  end

end