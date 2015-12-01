class CopyTaskData < ActiveRecord::Migration
  class TempTask < ActiveRecord::Base

  end

  class NewTask < ActiveRecord::Base
    belongs_to :taskable, polymorphic: true
    self.table_name = 'tasks'
    # to content the find_each function
    self.primary_key = 'id'
  end

  def up
    if Rails.env.production?
      TempTask.find_each do |temp_task|
        task = NewTask.new
        task.task_description_id = temp_task.task_description_id
        task.application_role = temp_task.application_role
        task.project_role = temp_task.project_role
        task.user_id = temp_task.user_id
        task.created_at = temp_task.created_at
        task.updated_at = temp_task.updated_at
        task.project_id = temp_task.project_id
        task.certification_path_id = temp_task.certification_path_id
        task.taskable_id = temp_task.taskable_id
        task.taskable_type = temp_task.taskable_type
        task.save
      end

      drop_table :temp_tasks
    end
  end

  def down
    if Rails.env.production?
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

      NewTask.find_each do |task|
        temp_task = TempTask.new
        temp_task.task_description_id = task.task_description_id
        temp_task.application_role = task.application_role
        temp_task.project_role = task.project_role
        temp_task.user_id = task.user_id
        temp_task.created_at = task.created_at
        temp_task.updated_at = task.updated_at
        temp_task.taskable_type = task.taskable_type + 'Task'
        temp_task.taskable_id = task.taskable_id
        temp_task.project_id = task.project_id
        temp_task.certification_path_id = task.certification_path_id
        temp_task.save
      end

      remove_reference :tasks, :taskable, polymorphic: :true
      remove_reference :tasks, :project
      remove_reference :tasks, :certification_path

      add_column :tasks, :type, :string
      add_column :tasks, :project_id, :integer
      add_column :tasks, :certification_path_id, :integer
      add_column :tasks, :scheme_mix_criterion_id, :integer
      add_column :tasks, :requirement_datum_id, :integer
      add_column :tasks, :scheme_mix_criteria_document_id, :integer

      NewTask.delete_all
    end
  end
end
