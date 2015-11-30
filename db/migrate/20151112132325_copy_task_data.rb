class CopyTaskData < ActiveRecord::Migration
  class TempTask < ActiveRecord::Base

  end

  def up

    TempTask.find_each do |temp_task|
      task = Task.new
      task.task_description_id = temp_task.task_description_id
      task.application_role = temp_task.application_role
      task.project_role = temp_task.project_role
      task.user_id = temp_task.user_id
      task.created_at = temp_task.created_at
      task.updated_at = temp_task.updated_at
      task.project_id = temp_task.project_id
      task.certification_path_id = temp_task.certification_path_id
      case temp_task.taskable_type
        when Project.name.demodulize
          project = Project.find(temp_task.taskable_id)
          task.taskable = project
        when CertificationPath.name.demodulize
          certification_path = CertificationPath.find(temp_task.taskable_id)
          task.taskable = certification_path
        when SchemeMixCriterion.name.demodulize
          scheme_mix_criterion = SchemeMixCriterion.find(temp_task.taskable_id)
          task.taskable = scheme_mix_criterion
        when RequirementDatum.name.demodulize
          requirement_datum = RequirementDatum.find(temp_task.taskable_id)
          task.taskable = requirement_datum
        when SchemeMixCriteriaDocument.name.demodulize
          scheme_mix_criteria_document = SchemeMixCriteriaDocument.find(temp_task.taskable_id)
          task.taskable = scheme_mix_criteria_document
      end
      task.save
    end

    drop_table :temp_tasks
  end

  def down

  end
end
