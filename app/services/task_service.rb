class TaskService

  def self::get_tasks(page: 1, per_page: 25,
                      user: nil,
                      project_id: nil,
                      certification_path_id: nil,
                      scheme_mix_criterion_id: nil,
                      requirement_datum_id: nil,
                      scheme_mix_criteria_document_id: nil,
                      from_datetime: nil)
    tasks = self::prepare_statement(user: user,
                                    project_id: project_id,
                                    certification_path_id: certification_path_id,
                                    scheme_mix_criterion_id: scheme_mix_criterion_id,
                                    requirement_datum_id: requirement_datum_id,
                                    scheme_mix_criteria_document_id: scheme_mix_criteria_document_id,
                                    from_datetime: from_datetime)
    tasks.distinct.order('tasks.project_id', :certification_path_id, :scheme_mix_criterion_id, :requirement_datum_id, :scheme_mix_criteria_document_id)
                  .paginate page: page, per_page: per_page
  end

  def self::count_tasks(
                        user: nil,
                        project_id: nil,
                        certification_path_id: nil,
                        scheme_mix_criterion_id: nil,
                        requirement_datum_id: nil,
                        scheme_mix_criteria_document_id: nil,
                        from_datetime: nil)
    tasks = self::prepare_statement(user: user,
                                    project_id: project_id,
                                    certification_path_id: certification_path_id,
                                    scheme_mix_criterion_id: scheme_mix_criterion_id,
                                    requirement_datum_id: requirement_datum_id,
                                    scheme_mix_criteria_document_id: scheme_mix_criteria_document_id,
                                    from_datetime: from_datetime)
    tasks.distinct.count
  end

  private

  def self::prepare_statement(user: nil,
                              project_id: nil,
                              certification_path_id: nil,
                              scheme_mix_criterion_id: nil,
                              requirement_datum_id: nil,
                              scheme_mix_criteria_document_id: nil,
                              from_datetime: nil)
    tasks = Task

    # User filter
    if user.present?
      if user.system_admin? || user.gord_manager? || user.gord_top_manager?
        check_project_role = ''
      else
        check_project_role = "or (projects_users.role = tasks.project_role and projects_users.user_id = #{user.id})"
      end
      tasks = tasks.joins(project: [:projects_users]).where("tasks.user_id = #{user.id} or application_role = #{User.roles[user.role]} #{check_project_role}")
    end

    # Project filter
    if project_id.present?
      tasks = tasks.where(project_id: project_id)
    end

    # Certification path filter
    if certification_path_id.present?
      tasks = tasks.where(certification_path_id: certification_path_id)
    end

    # Scheme mix criterion filter
    if scheme_mix_criterion_id.present?
      tasks = tasks.where(scheme_mix_criterion_id: scheme_mix_criterion_id)
    end

    # Requirement datum filter
    if requirement_datum_id.present?
      tasks = tasks.where(requirement_datum_id: requirement_datum_id)
    end

    # Scheme mix criteria document filter
    if scheme_mix_criteria_document_id.present?
      tasks = tasks.where(scheme_mix_criteria_document_id: scheme_mix_criteria_document_id)
    end

    # Date filter
    if from_datetime.present?
      tasks = tasks.where('tasks.updated_at > ?', from_datetime)
    end

    tasks
  end

end