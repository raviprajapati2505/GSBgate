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
    tasks.distinct.order('tasks.project_id', :certification_path_id)
                  .page(page).per(per_page)
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
      if user.is_users_admin? || user.is_credentials_admin?
        tasks = tasks.where("application_role = #{User.roles[user.role]}")
      else
        if user.is_system_admin? || user.is_gsb_manager? || user.is_gsb_top_manager? || user.is_gsb_admin?
          check_project_role = ''
        else
          check_project_role = "or (projects_users.role = tasks.project_role and projects_users.user_id = #{user.id})"
        end
        tasks = tasks.joins(project: [:projects_users]).where("tasks.user_id = #{user.id} or application_role = #{User.roles[user.role]} #{check_project_role}")
      end
    end

    unless user.is_users_admin? || user.is_credentials_admin?
      # All tasks of user according to projects_user's certification_team_type
      tasks = 
        tasks
        .left_outer_joins(
          project: :projects_users, 
          certification_path: :certificate
        )
        .where(
          "projects_users.certification_team_type IN (#{ProjectsUser.certification_team_types[:other]})"
        )
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
      # tasks = tasks.where(scheme_mix_criterion_id: scheme_mix_criterion_id)
      task = Task.arel_table
      requirement_datum = RequirementDatum.arel_table
      join_on_1 = task.create_on(task[:taskable_id].eq(requirement_datum[:id]))
      outer_join_1 = task.create_join(requirement_datum, join_on_1, Arel::Nodes::OuterJoin)
      scheme_mix_criteria_requirement_datum = SchemeMixCriteriaRequirementDatum.arel_table
      join_on_2 = requirement_datum.create_on(requirement_datum[:id].eq(scheme_mix_criteria_requirement_datum[:requirement_datum_id]))
      outer_join_2 = requirement_datum.create_join(scheme_mix_criteria_requirement_datum, join_on_2, Arel::Nodes::OuterJoin)
      scheme_mix_criteria_document = SchemeMixCriteriaDocument.arel_table
      join_on_3 = task.create_on(task[:taskable_id].eq(scheme_mix_criteria_document[:id]))
      outer_join_3 = task.create_join(scheme_mix_criteria_document, join_on_3, Arel::Nodes::OuterJoin)

      tasks = tasks.joins(outer_join_1, outer_join_2, outer_join_3).where('(tasks.taskable_type = \'SchemeMixCriterion\' and tasks.taskable_id = ?) or (tasks.taskable_type = \'RequirementDatum\' and scheme_mix_criteria_requirement_data.scheme_mix_criterion_id = ?) or (tasks.taskable_type = \'SchemeMixCriteriaDocument\' and scheme_mix_criteria_documents.scheme_mix_criterion_id = ?)', scheme_mix_criterion_id, scheme_mix_criterion_id, scheme_mix_criterion_id)
    end

    # Requirement datum filter
    # if requirement_datum_id.present?
    # end

    # Scheme mix criteria document filter
    # if scheme_mix_criteria_document_id.present?
    # end

    # Date filter
    if from_datetime.present?
      tasks = tasks.where('tasks.updated_at > ?', from_datetime)
    end

    tasks
  end

end