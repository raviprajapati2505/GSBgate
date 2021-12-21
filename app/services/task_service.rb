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
      if user.system_admin? || user.gsas_trust_manager? || user.gsas_trust_top_manager? || user.gsas_trust_admin?
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

    # All tasks of user according to projects_user's certification_team_type
    unless (project_id.present? && certification_path_id.present?)
      tasks = tasks.left_outer_joins(project: :projects_users, certification_path: :certificate).where("SELECT CASE WHEN certificates.certification_type = #{Certificate.certification_types['letter_of_conformance']} THEN projects_users.certification_team_type = #{ProjectsUser.certification_team_types['Letter of Conformance']} WHEN certificates.certification_type = #{Certificate.certification_types['final_design_certificate']} THEN projects_users.certification_team_type = #{ProjectsUser.certification_team_types['Final Design Certificate']} WHEN projects.certificate_type = 3 THEN projects_users.certification_team_type IN (#{ProjectsUser.certification_team_types['Letter of Conformance']}, #{ProjectsUser.certification_team_types['Final Design Certificate']}) WHEN projects.certificate_type IN (1, 2) THEN projects_users.certification_team_type IN (#{ProjectsUser.certification_team_types['Other']}) ELSE projects_users.certification_team_type IN (#{ProjectsUser.certification_team_types['Letter of Conformance']}, #{ProjectsUser.certification_team_types['Final Design Certificate']}, #{ProjectsUser.certification_team_types['Other']}) END")
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