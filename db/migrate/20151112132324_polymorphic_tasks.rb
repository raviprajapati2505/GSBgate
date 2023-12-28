class PolymorphicTasks < ActiveRecord::Migration[4.2]
  # class TempTask < ActiveRecord::Base
  #
  # end
  #
  # class OldTask < ActiveRecord::Base
  #   self.table_name = 'tasks'
  #   # to content the find_each function
  #   self.primary_key = 'id'
  # end

  def up
    # if Rails.env.production?
    #   create_table "temp_tasks", force: :cascade do |t|
    #     t.integer  "task_description_id",             null: false
    #     t.integer  "application_role"
    #     t.integer  "project_role"
    #     t.integer  "user_id"
    #     t.datetime "created_at",                      null: false
    #     t.datetime "updated_at",                      null: false
    #     t.integer  "taskable_id"
    #     t.integer  "certification_path_id"
    #     t.integer  "project_id"
    #     t.string   "taskable_type"
    #   end
    #
    #   # Without this renaming rails will try to find the inheriting class
    #   rename_column :tasks, :type, :temp_type
    #
    #   OldTask.find_each do |task|
    #     temp_task = TempTask.new
    #     temp_task.task_description_id = task.task_description_id
    #     temp_task.application_role = task.application_role
    #     temp_task.project_role = task.project_role
    #     temp_task.user_id = task.user_id
    #     temp_task.created_at = task.created_at
    #     temp_task.updated_at = task.updated_at
    #     temp_task.taskable_type = task.temp_type[0..-5]
    #     temp_task.project_id = task.project_id
    #     temp_task.certification_path_id = task.certification_path_id
    #     case temp_task.taskable_type
    #       when Project.name.demodulize
    #         temp_task.taskable_id = task.project_id
    #       when CertificationPath.name.demodulize
    #         temp_task.taskable_id = task.certification_path_id
    #       when SchemeMixCriterion.name.demodulize
    #         temp_task.taskable_id = task.scheme_mix_criterion_id
    #       when RequirementDatum.name.demodulize
    #         temp_task.taskable_id = task.requirement_datum_id
    #       when SchemeMixCriteriaDocument.name.demodulize
    #         temp_task.taskable_id = task.scheme_mix_criteria_document_id
    #     end
    #     temp_task.save
    #   end

      remove_column :tasks, :temp_type, :string
      remove_column :tasks, :project_id, :integer
      remove_column :tasks, :certification_path_id, :integer
      remove_column :tasks, :scheme_mix_criterion_id, :integer
      remove_column :tasks, :requirement_datum_id, :integer
      remove_column :tasks, :scheme_mix_criteria_document_id, :integer

      add_reference :tasks, :taskable, polymorphic: :true, index: true
      add_reference :tasks, :project, index: true, foreign_key: true
      add_reference :tasks, :certification_path, index: true, foreign_key: true

      # OldTask.delete_all
    # end
  end

  def down
    # if Rails.env.production?
    #   TempTask.find_each do |temp_task|
    #     task = OldTask.new
    #     task.task_description_id = temp_task.task_description_id
    #     task.application_role = temp_task.application_role
    #     task.project_role = temp_task.project_role
    #     task.user_id = temp_task.user_id
    #     task.created_at = temp_task.created_at
    #     task.updated_at = temp_task.updated_at
    #     task.project_id = temp_task.project_id
    #     task.certification_path_id = temp_task.certification_path_id
    #     task.type = temp_task.taskable_type
    #     case temp_task.taskable_type
    #       when SchemeMixCriterion.name.demodulize
    #         task.scheme_mix_criterion_id = temp_task.taskable_id
    #       when RequirementDatum.name.demodulize
    #         task.requirement_datum_id = temp_task.taskable_id
    #       when SchemeMixCriteriaDocument.name.demodulize
    #         task.scheme_mix_criteria_document_id = temp_task.taskable_id
    #     end
    #     task.save
    #   end
    #
    #   drop_table :temp_tasks
    # end
  end
end
