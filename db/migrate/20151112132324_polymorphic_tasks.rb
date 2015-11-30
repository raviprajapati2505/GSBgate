class PolymorphicTasks < ActiveRecord::Migration
  class TempTask < ActiveRecord::Base

  end

  def up

    # rename_column :tasks, :project_id, :project_id_old
    # rename_column :tasks, :certification_path_id, :certification_path_id_old

    # add_reference :tasks, :taskable, polymorphic: :true, index: true
    # add_reference :tasks, :project, index: true, foreign_key: true
    # add_reference :tasks, :certification_path, index: true, foreign_key: true

    create_table "temp_tasks", force: :cascade do |t|
      t.integer  "task_description_id",             null: false
      t.integer  "application_role"
      t.integer  "project_role"
      t.integer  "user_id"
      t.datetime "created_at",                      null: false
      t.datetime "updated_at",                      null: false
      t.integer  "taskable_id"
      t.integer  "certification_path_id"
      t.integer  "project_id"
      t.string   "taskable_type"
    end

      Task.find_each do |task|
        temp_task = TempTask.new
        temp_task.task_description_id = task.task_description_id
        temp_task.application_role = task.application_role
        temp_task.project_role = task.project_role
        temp_task.user_id = task.user_id
        temp_task.created_at = task.created_at
        temp_task.updated_at = task.updated_at
        temp_task.taskable_type = task.type
        temp_task.project_id = task.project_id
        temp_task.certification_path_id = task.certification_path_id
        case task.type
          when Project.name.demodulize
            temp_task.taskable_id = task.project_id
          when CertificationPath.name.demodulize
            temp_task.taskable_id = task.certification_path_id
          when SchemeMixCriterion.name.demodulize
            temp_task.taskable_id = task.scheme_mix_criterion_id
          when RequirementDatum.name.demodulize
            temp_task.taskable_id = task.requirement_datum_id
          when SchemeMixCriteriaDocument.name.demodulize
            temp_task.taskable_id = task.scheme_mix_criteria_document_id
        end
        temp_task.save
      end

    remove_column :tasks, :type, :string
    remove_column :tasks, :project_id, :integer
    remove_column :tasks, :certification_path_id, :integer
    remove_column :tasks, :scheme_mix_criterion_id, :integer
    remove_column :tasks, :requirement_datum_id, :integer
    remove_column :tasks, :scheme_mix_criteria_document_id, :integer

    add_reference :tasks, :taskable, polymorphic: :true, index: true
    add_reference :tasks, :project, index: true, foreign_key: true
    add_reference :tasks, :certification_path, index: true, foreign_key: true

    Task.delete_all
  end

  def down

  end
end
